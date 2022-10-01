import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_earth/flutter_earth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nisn/models/nisn_data.dart';
import 'package:nisn/services/navigation.dart';
import 'package:nisn/services/ui_services.dart';
import 'package:nisn/views/detailed_area_view.dart';
import 'package:nisn/views/temporal_and_spatial_view.dart';
import 'package:nisn/widgets/proceed_button.dart';
import 'package:nisn/widgets/year_selector_bottom_sheet.dart';

import '../constants/images.dart';
import '../constants/ui.dart';
import '../services/location_service.dart';

class EarthView extends StatefulWidget {
  EarthView({
    Key key,
  }) : super(key: key);

  @override
  State<EarthView> createState() => _EarthViewState();
}

class _EarthViewState extends State<EarthView>
    with AutomaticKeepAliveClientMixin {
  FlutterEarthController _controller;
  bool processing = false;
  List<PlaceSearch> searchResults;
  final placesService = PlacesService();
  bool searching = false;
  LatLon _position = LatLon(0, 0);

  void _onMapCreated(FlutterEarthController controller) {
    _controller = controller;
  }

  void _onCameraMove(LatLon latLon, double zoom) {
    _position = latLon.inDegrees();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.asset(
              galaxy,
              color: Colors.black.withOpacity(0.7),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        ),
        Center(
          child: FlutterEarth(
            url: 'http://mt0.google.com/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}',
            radius: 180,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
          ),
        ),
        Center(
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 35,
          ),
        ),
        buildFloatingSearchBar(),
        if (_position != LatLon(0, 0))
          Positioned(
            bottom: 5,
            left: 10,
            right: 10,
            child: Wrap(
              children: [
                ProceedButton(
                  onTap: () {
                    NavigationService().push(
                      DetailedAreaView(
                        position: _position,
                      ),
                    );
                  },
                  text: "Explore Ionosphere Data in this area",
                ),
                SizedBox(
                  height: 10,
                ),
                ProceedButton(
                  processable: true,
                  processing: processing,
                  onTap: () async {
                    int year = await UIServices().showDatSheet(
                      YearSelectorBottomSheet(),
                      true,
                      context,
                    );

                    if (year != null) {
                      DateTime dd = DateTime(
                        year,
                        1,
                        1,
                      );

                      setState(() {
                        processing = true;
                      });

                      List<NisnData> data = [];

                      FirebaseFirestore.instance
                          .collection(NisnData.DIRECTORY)
                          .where(
                            NisnData.TIME,
                            isLessThanOrEqualTo: dd
                                .add(Duration(days: 365))
                                .millisecondsSinceEpoch,
                          )
                          .orderBy(NisnData.TIME)
                          .where(
                            NisnData.TIME,
                            isGreaterThanOrEqualTo: dd.millisecondsSinceEpoch,
                          )
                          .get()
                          .then(
                        (n) {
                          for (var element in n.docs) {
                            NisnData nisnData = NisnData.fromSnapshot(element);

                            data.add(nisnData);
                          }

                          setState(() {
                            processing = false;
                          });

                          NavigationService().push(
                            TemporalAndSpatialView(
                              nisnData: data,
                              year: year,
                            ),
                          );
                        },
                      );
                    }
                  },
                  text: "View the High Temporal and high spatial map",
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      onSubmitted: (query) {
        searchPlaces(query);
      },
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      automaticallyImplyBackButton: false,
      progress: searching,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        searchPlaces(query);
      },
      clearQueryOnClose: true,
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: true,
          showIfClosed: false,
          builder: (context, animation) {
            final bar = FloatingSearchAppBar.of(context);

            return ValueListenableBuilder<String>(
              valueListenable: bar.queryNotifer,
              builder: (context, query, _) {
                final isEmpty = query.trim().isEmpty;

                return SearchToClear(
                  isEmpty: isEmpty,
                  size: 24,
                  color: bar.style.iconColor,
                  duration: Duration(milliseconds: 900) * 0.5,
                  onTap: () {
                    if (!isEmpty) {
                      bar.clear();
                      searchResults = null;
                      if (mounted) setState(() {});
                    } else {
                      bar.isOpen =
                          !bar.isOpen || (!bar.hasFocus && bar.isAlwaysOpened);
                    }
                  },
                );
              },
            );
          },
        ),
      ],
      builder: (context, transition) {
        if (searchResults != null) {
          return ClipRRect(
            borderRadius: standardBorderRadius,
            child: Material(
              color: Colors.white,
              elevation: standardElevation,
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setSelectedLocation(
                            searchResults[index].placeId,
                            null,
                            false,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          margin: EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 5,
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(
                            searchResults[index].description,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  searchPlaces(String searchTerm) async {
    if (searchTerm.trim().isNotEmpty) {
      if (mounted) {
        setState(() {
          searching = true;
        });
      }
      await placesService.getAutocomplete(searchTerm).then((value) {
        searchResults = value;
        searching = false;
        if (mounted) setState(() {});
      });
    }
  }

  setSelectedLocation(String placeId, LatLng pos, bool onTap) async {
    searchResults = null;
    var sLocation = await placesService.getPlace(placeId);

    var lat = sLocation.geometry.location.lat;
    var long = sLocation.geometry.location.lng;

    _position = LatLon(lat, long);

    _controller.animateCamera(
      newLatLon: LatLon(lat, long).inRadians(),
      riseZoom: 2.2,
      fallZoom: 15,
      panSpeed: 500,
      riseSpeed: 3,
      fallSpeed: 2,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
