import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nisn/constants/ui.dart';
import 'package:nisn/widgets/custom_dialog_box.dart';
import 'package:nisn/widgets/top_back_bar.dart';
import 'package:nisn/services/location_service.dart';

class MapView extends StatefulWidget {
  final bool singleLocation;
  final List<Map<String, LatLng>> locations;
  final bool selectable;

  MapView({
    Key key,
    @required this.singleLocation,
    @required this.locations,
    @required this.selectable,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool approved = false;
  List<LatLng> _locations = [];
  TextEditingController controller = TextEditingController();
  Set<Marker> markers = {};
  GoogleMapController mapController;
  final placesService = PlacesService();
  bool searching = false;
  List<PlaceSearch> searchResults;

  @override
  void initState() {
    super.initState();
    if (widget.locations != null) {
      for (var element in widget.locations) {
        _locations.add(element.entries.first.value);
        markers.add(
          Marker(
            markerId:
                MarkerId(DateTime.now().millisecondsSinceEpoch.toString()),
            position: element.entries.first.value,
            infoWindow: InfoWindow(
              title: element.entries.first.key ?? "Here",
              snippet: "This is the location",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return popAndReturn();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BackBar(
                icon: null,
                onPressed: popAndReturn,
                text: widget.selectable != null &&
                        widget.selectable &&
                        widget.singleLocation
                    ? "Please tap the location on the Map"
                    : widget.selectable != null &&
                            widget.selectable &&
                            !widget.singleLocation
                        ? "Please tap the locations on the Map"
                        : "Map",
              ),
              if (widget.selectable != null && widget.selectable)
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: OutlinedButton(
                    onPressed: () {
                      clearSelectedLocation();
                    },
                    child: Text(
                      widget.singleLocation
                          ? "Clear Selected Location"
                          : "Clear Selected Locations",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Visibility(
                visible: markers.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: Text(
                    "${markers.length} Locations",
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderDouble),
                    topRight: Radius.circular(borderDouble),
                  ),
                  child: Stack(
                    children: [
                      GoogleMap(
                        mapToolbarEnabled: false,
                        markers: markers,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        onTap: (pos) async {
                          if (widget.selectable != null && widget.selectable) {
                            setSelectedLocation(null, pos, true);
                          }
                        },
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: const LatLng(0, 0),
                          zoom: 2,
                        ),
                      ),
                      buildFloatingSearchBar(),
                      Visibility(
                        visible: _locations.isNotEmpty,
                        child: Positioned(
                          bottom: 10,
                          left: 10,
                          child: GestureDetector(
                            onTap: () {
                              popAndReturn();
                            },
                            child: Material(
                              borderRadius: standardBorderRadius,
                              color: Colors.blue,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: standardBorderRadius,
                                ),
                                child: Text(
                                  "Done",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  popAndReturn() {
    Navigator.of(context).pop(_locations);
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

  clearSelectedLocation() {
    _locations.clear();
    markers.clear();
    searchResults = null;

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  setSelectedLocation(String placeId, LatLng pos, bool onTap) async {
    if (widget.singleLocation) {
      if (onTap) {
        _locations.clear();
        markers.clear();
        _locations.add(pos);

        markers.add(
          Marker(
            markerId: MarkerId("Here"),
            position: pos,
            infoWindow: InfoWindow(
              title: "Here",
              snippet: "This is the location",
            ),
          ),
        );
        if (mounted) setState(() {});
      } else {
        _locations.clear();
        markers.clear();
        searchResults = null;
        var sLocation = await placesService.getPlace(placeId);

        _locations.add(LatLng(
          sLocation.geometry.location.lat,
          sLocation.geometry.location.lng,
        ));

        mapController
            .animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              sLocation.geometry.location.lat,
              sLocation.geometry.location.lng,
            ),
            15,
          ),
        )
            .then((value) {
          markers.add(
            Marker(
              markerId: MarkerId("Here"),
              position: LatLng(
                sLocation.geometry.location.lat,
                sLocation.geometry.location.lng,
              ),
              infoWindow: InfoWindow(
                title: sLocation.name,
                snippet: "This is where the Store is",
              ),
            ),
          );

          if (mounted) setState(() {});
        });
      }
    } else {
      if (onTap) {
        _locations.add(pos);

        markers.add(
          Marker(
            markerId:
                MarkerId(DateTime.now().millisecondsSinceEpoch.toString()),
            position: pos,
            infoWindow: InfoWindow(
              title: "Here",
              snippet: "This is where the Store is",
            ),
          ),
        );
        if (mounted) setState(() {});
      } else {
        searchResults = null;
        var sLocation = await placesService.getPlace(placeId);

        _locations.add(LatLng(
          sLocation.geometry.location.lat,
          sLocation.geometry.location.lng,
        ));

        mapController
            .animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              sLocation.geometry.location.lat,
              sLocation.geometry.location.lng,
            ),
            15,
          ),
        )
            .then((value) {
          markers.add(
            Marker(
              markerId:
                  MarkerId(DateTime.now().millisecondsSinceEpoch.toString()),
              position: LatLng(
                sLocation.geometry.location.lat,
                sLocation.geometry.location.lng,
              ),
              infoWindow: InfoWindow(
                title: sLocation.name,
                snippet: "This is where the Store is",
              ),
            ),
          );

          setState(() {});
        });
      }
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    if (markers.isEmpty) {
      await _determinePosition().then((v) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              v.latitude,
              v.longitude,
            ),
            15,
          ),
        );
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (context) {
            return CustomDialogBox(
              showSignInButton: false,
              bodyText: error.toString(),
              buttonText: "Settings",
              onButtonTap: () async {
                if (error ==
                    "Location services are disabled. Please click here and turn on your location") {
                  await Geolocator.openLocationSettings();
                } else {
                  await Geolocator.openAppSettings();
                }
              },
              showOtherButton: true,
            );
          },
        );
      });
    } else {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          widget.locations[0].entries.first.value,
          15,
        ),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
          'Location services are disabled. Please click here and turn on your location');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot find your current location. Please tap the button below, then Permissions and then grant location permissions');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions have been denied (actual value: $permission). Please grant the app the needed permissions to proceed.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}
