import 'package:cloud_firestore/cloud_firestore.dart';

class NisnYear {
  static const DIRECTORY = "years";
  static const IMAGE = "image";
  static const TEXT = "text";

  String _year;
  String _image;

  String get year => _year;
  String get image => _image;

  NisnYear.fromSnaphot(DocumentSnapshot snapshot) {
    Map pp = snapshot.data() as Map;

    _year = pp[TEXT];
    _image = pp[IMAGE];
  }
}
