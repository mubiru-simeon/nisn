import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryLocation {
  static const DIRECTORY = "deliveryLocations";
  static const LAT = "lat";
  static const LONG = "long";
  static const NAME = "name";

  dynamic _lat;
  dynamic _long;
  String _name;
  String _id;

  dynamic get lat => _lat;
  dynamic get long => _long;
  String get name => _name;
  String get id => _id;

  DeliveryLocation.fromData(LatLng loc) {
    _lat = loc.latitude;
    _long = loc.longitude;
    _name = "Location";
  }

  DeliveryLocation.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;
    _id = snapshot.id;
    _lat = pp[LAT];
    _long = pp[LONG];
    _name = pp[NAME] ?? "Location";
  }
}
