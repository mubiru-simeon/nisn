import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  static const DIRECTORY = "notifications";
  static const NOTIFICATIONCOUNT = "notificationCount";

  static const TIME = "time";
  static const ID = "id";
  static const AMOUNT = "amount";
  static const REASON = "reason";
  static const RECEPIENT = "recepient";
  static const SERVICEPROVIDER = "serviceProvider";
  static const PARTNER = "partner";
  static const CUSTOMER = "customer";
  static const SECONDARYID = "secondaryID";
  static const TITLE = "title";
  static const BODY = "body";
  static const THINGTYPE = "thingType";
  static const RESCHEDULER = "rescheduler";
  static const DELETER = "deleter";

  int _time;
  String _recepient;
  String _notificationId;
  String _primaryId;
  String _secondaryId;
  String _reason;
  String _partnerId;
  String _customerId;
  String _serviceProviderId;
  String _thingtype;
  String _rescheduler;
  String _deleter;
  String _body;
  String _title;

  int get time => _time;
  String get notificationId => _notificationId;
  String get thingType => _thingtype;
  String get partnerID => _partnerId;
  String get primaryId => _primaryId;
  String get reason => _reason;
  String get rescheduler => _rescheduler;
  String get serviceProviderId => _serviceProviderId;
  String get secondaryId => _secondaryId;
  String get customerID => _customerId;
  String get recepient => _recepient;
  String get deleter => _deleter;
  String get title => _title;
  String get body => _body;

  NotificationModel.fromSnapshot(
    DocumentSnapshot snapshot,
    BuildContext context,
  ) {
    Map pp = snapshot.data() as Map;

    _title = pp[TITLE] ?? "";
    _body = pp[BODY] ?? "";
    _time = pp[TIME];
    _primaryId = pp[ID];
    _reason = pp[REASON];
    _notificationId = snapshot.id;
    _recepient = pp[RECEPIENT];
    _partnerId = pp[PARTNER];
    _secondaryId = pp[SECONDARYID];
    _rescheduler = pp[RESCHEDULER];
    _thingtype = pp[THINGTYPE];
    _customerId = pp[CUSTOMER];
    _serviceProviderId = pp[SERVICEPROVIDER];
    _deleter = pp[DELETER];
  }

  NotificationModel.fromData(
    String receiver,
    String title,
    String body,
    DateTime time,
  ) {
    _recepient = receiver;
    _title = title;
    _body = body;
    _time = time.millisecondsSinceEpoch;
  }
}
