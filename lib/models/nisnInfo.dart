import 'package:cloud_firestore/cloud_firestore.dart';

class NisnInfo {
  static const DIRECTORY = "nisnInfo";

  static const TITLE = "title";
  static const DESC = "desc";
  static const TIME = "time";
  static const ADDER = "adder";
  static const IMAGES = "images";

  String _title;
  String _desc;
  int _date;
  List _images;

  String get title => _title;
  String get desc => _desc;
  int get date => _date;
  List get images => _images;

  NisnInfo.fromSnapshot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _title = pp[TITLE];
    _desc = pp[DESC];
    _date = pp[TIME];
    _images = pp[IMAGES] ?? [];
  }
}
