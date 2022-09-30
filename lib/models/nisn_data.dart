import 'package:cloud_firestore/cloud_firestore.dart';

class NisnData {
  static const DIRECTORY = "nisnData";

  static const TIME = "time";
  static const YEAR = "year";
  static const LATITUDE = "latitude";
  static const LONGITUDE = "longitude";
  static const ALTITUDE = "altitude";
  static const GEOX = "geo_x";
  static const GEOY = "geo_y";
  static const GEOZ = "geo_z";
  static const ELECTRONDENSITY = "electronDensity";
  static const GEOVY = "geo_vy";
  static const GEOVX = "geo_vx";
  static const GEOVZ = "geo_vz";
  static const ADDER = "adder";
  static const DATEADDED = "dateAdded";
  static const APPROVED = "approved";

  dynamic _lat;
  dynamic _long;
  dynamic _alt;
  dynamic _geox;
  dynamic _geoy;
  dynamic _geoz;
  dynamic _geovx;
  dynamic _geovy;
  String _id;
  dynamic _geovz;
  int _date;
  dynamic _electronDensity;

  dynamic get lat => _lat;
  String get id => _id;
  int get date => _date;
  dynamic get long => _long;
  dynamic get alt => _alt;
  dynamic get geox => _geox;
  dynamic get geoy => _geoy;
  dynamic get geoz => _geoz;
  dynamic get geovx => _geovx;
  dynamic get geovy => _geovy;
  dynamic get geovz => _geovz;
  dynamic get electronDensity => _electronDensity;

  NisnData.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _geovx = pp[GEOVX];
    _geovy = pp[GEOVY];
    _date = pp[DATEADDED];
    _id = snapshot.id;
    _alt = pp[ALTITUDE];
    _electronDensity = pp[ELECTRONDENSITY];
    _geovz = pp[GEOVZ];
    _geox = pp[GEOX];
    _geoz = pp[GEOZ];
    _geoy = pp[GEOY];
    _lat = pp[LATITUDE];
    _long = pp[LONGITUDE];
  }
}
