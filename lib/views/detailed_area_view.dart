import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_earth/flutter_earth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nisn/widgets/loading_widget.dart';
import 'package:nisn/widgets/top_back_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/geohashing_item.dart';
import '../models/nisn_data.dart';
import '../services/geo_hashing.dart';

class DetailedAreaView extends StatefulWidget {
  final LatLon position;
  DetailedAreaView({
    Key key,
    @required this.position,
  }) : super(key: key);

  @override
  State<DetailedAreaView> createState() => _DetailedAreaViewState();
}

class _DetailedAreaViewState extends State<DetailedAreaView> {
  GoogleMapController mapController;
  List<_ChartData> chartData = [];
  TrackballBehavior _topGraphTrackballBehavior;
  TrackballBehavior _middleGraphTrackballBehavior;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _topGraphTrackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
    );

    _middleGraphTrackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
    );

    markers = {
      Marker(
        infoWindow: InfoWindow(
          title: "Location",
          snippet: "This is the center",
        ),
        markerId: MarkerId(
          DateTime.now().millisecondsSinceEpoch.toString(),
        ),
        position: LatLng(
          widget.position.latitude,
          widget.position.longitude,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "Ionosphere Data Visualisation",
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: GoogleMap(
                        mapType: MapType.terrain,
                        zoomGesturesEnabled: true,
                        mapToolbarEnabled: false,
                        markers: markers,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        onTap: (pos) async {},
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: const LatLng(0, 0),
                          zoom: 2,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    StreamBuilder(
                        stream: Geoflutterfire()
                            .collection(
                                collectionRef: FirebaseFirestore.instance
                                    .collection(NisnData.DIRECTORY))
                            .within(
                              center: Geoflutterfire().point(
                                latitude: widget.position.latitude,
                                longitude: widget.position.longitude,
                              ),
                              radius: 1000,
                              field: GeoHashedItem.POSITION,
                            ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return LoadingWidget();
                          } else {
                            if (snapshot.data == null) {
                              return Center(
                                child: Text(
                                    "Insufficient Ionosphere Data for this region"),
                              );
                            } else {
                              List<NisnData> pp = [];

                              snapshot.data.forEach(
                                (e) {
                                  NisnData data = NisnData.fromSnapshot(e);

                                  pp.add(data);
                                },
                              );

                              for (var element in pp) {
                                var freq = sqrt(
                                    (element.electronDensity * 100000000000) /
                                        (1.24 * 10000));

                                chartData.add(
                                  _ChartData(
                                    element.alt,
                                    element.electronDensity,
                                    freq,
                                  ),
                                );
                              }

                              return pp.isEmpty
                                  ? Center(
                                      child: Text(
                                          "Insufficient Ionosphere Data for this region"),
                                    )
                                  : Column(
                                      children: [
                                        SfCartesianChart(
                                          plotAreaBorderWidth: 0,
                                          title: ChartTitle(
                                            text:
                                                'Graph of Electron Density Against Altitude',
                                          ),
                                          legend: Legend(isVisible: true),
                                          primaryXAxis: CategoryAxis(
                                            title: AxisTitle(
                                              text:
                                                  "Electron Density in exp11 (e/m^3)",
                                            ),
                                            majorGridLines:
                                                const MajorGridLines(
                                              width: 0,
                                            ),
                                            labelRotation: -45,
                                          ),
                                          primaryYAxis: NumericAxis(
                                            title: AxisTitle(
                                              text: "Altitude (km)",
                                            ),
                                            axisLine: const AxisLine(width: 0),
                                            majorTickLines:
                                                const MajorTickLines(size: 0),
                                          ),
                                          series: <
                                              StackedLineSeries<NisnData,
                                                  String>>[
                                            StackedLineSeries<NisnData, String>(
                                              dataSource: pp,
                                              xValueMapper:
                                                  (NisnData sales, _) => sales
                                                      .electronDensity
                                                      .toStringAsFixed(1),
                                              yValueMapper:
                                                  (NisnData sales, _) =>
                                                      sales.alt,
                                              name: 'Data',
                                              markerSettings:
                                                  const MarkerSettings(
                                                isVisible: true,
                                              ),
                                            ),
                                          ],
                                          trackballBehavior:
                                              _topGraphTrackballBehavior,
                                        ),
                                        SizedBox(
                                          height: 25,
                                        ),
                                        SfCartesianChart(
                                          plotAreaBorderWidth: 0,
                                          title: ChartTitle(
                                            text:
                                                'Graph of Electron Density and Critical Frequency Against Altitude',
                                          ),
                                          legend: Legend(
                                              isVisible: true,
                                              position: LegendPosition.bottom),
                                          primaryXAxis: CategoryAxis(
                                            majorGridLines:
                                                const MajorGridLines(
                                              width: 0,
                                            ),
                                            title: AxisTitle(
                                              text: "Altitude (km)",
                                            ),
                                            labelRotation: -45,
                                          ),
                                          primaryYAxis: NumericAxis(
                                            axisLine: const AxisLine(width: 0),
                                            majorTickLines:
                                                const MajorTickLines(size: 0),
                                          ),
                                          series: getMiddleGraphData(),
                                          trackballBehavior:
                                              _middleGraphTrackballBehavior,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        )
                                      ],
                                    );
                            }
                          }
                        }),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<LineSeries<_ChartData, num>> getMiddleGraphData() {
    return <LineSeries<_ChartData, num>>[
      LineSeries<_ChartData, num>(
          animationDuration: 2500,
          dataSource: chartData,
          xValueMapper: (_ChartData sales, _) => sales.x,
          yValueMapper: (_ChartData sales, _) => sales.y,
          width: 2,
          name: 'Electron Density (e/m^3)',
          markerSettings: const MarkerSettings(isVisible: true)),
      LineSeries<_ChartData, num>(
          animationDuration: 2500,
          dataSource: chartData,
          width: 2,
          name: 'Critical Frequency (KHz)',
          xValueMapper: (_ChartData sales, _) => sales.x,
          yValueMapper: (_ChartData sales, _) => sales.y2,
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
          LatLng(
            widget.position.latitude,
            widget.position.longitude,
          ),
          10),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.y2);
  final double x;
  final double y;
  final double y2;
}
