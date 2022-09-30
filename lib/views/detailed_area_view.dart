import 'dart:async';

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
  TrackballBehavior _trackballBehavior;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _trackballBehavior = TrackballBehavior(
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

                              return pp.isEmpty
                                  ? Center(
                                      child: Text(
                                          "Insufficient Ionosphere Data for this region"),
                                    )
                                  : SfCartesianChart(
                                      plotAreaBorderWidth: 0,
                                      title: ChartTitle(
                                        text:
                                            'Graph of Electron Density Against Altitude',
                                      ),
                                      legend: Legend(isVisible: true),
                                      primaryXAxis: CategoryAxis(
                                        majorGridLines: const MajorGridLines(
                                          width: 0,
                                        ),
                                        labelRotation: -45,
                                      ),
                                      primaryYAxis: NumericAxis(
                                        axisLine: const AxisLine(width: 0),
                                        majorTickLines:
                                            const MajorTickLines(size: 0),
                                      ),
                                      series: <
                                          StackedLineSeries<NisnData, String>>[
                                        StackedLineSeries<NisnData, String>(
                                          dataSource: pp,
                                          xValueMapper: (NisnData sales, _) =>
                                              sales.electronDensity
                                                  .toStringAsFixed(1),
                                          yValueMapper: (NisnData sales, _) =>
                                              sales.alt,
                                          name: 'Data',
                                          markerSettings: const MarkerSettings(
                                            isVisible: true,
                                          ),
                                        ),
                                      ],
                                      trackballBehavior: _trackballBehavior,
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
