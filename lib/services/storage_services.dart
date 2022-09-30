import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/basic.dart';
import '../models/geohashing_item.dart';
import '../models/notification.dart';
import '../models/user.dart';
import 'auth_provider_widget.dart';
import 'communications.dart';
import 'geo_hashing.dart';
import 'location_service.dart';
import 'map_generation.dart';

class StorageServices {
  Future<String> handleLocationStuffForItems(
    dynamic lat,
    dynamic long,
    String thingID,
    String country,
    String city,
    String address,
    String directory,
  ) async {
    if (country != null) {
      await FirebaseFirestore.instance
          .collection(directory)
          .doc(thingID)
          .update(
        {
          GeoHashedItem.ADDRESS: address,
          GeoHashedItem.COUNTRY: country,
          GeoHashedItem.CITY: city,
        },
      );

      return "done";
    } else {
      GeoFirePoint geoFirePoint = Geoflutterfire().point(
        latitude: double.parse(lat.toString()),
        longitude: double.parse(long.toString()),
      );

      return await LocationService()
          .getAddressFromLatLng(LatLng(
              double.parse(long.toString()), double.parse(long.toString())))
          .then(
        (value) {
          {
            if (value != null) {
              FirebaseFirestore.instance
                  .collection(directory)
                  .doc(thingID)
                  .update(
                {
                  GeoHashedItem.ADDRESS: value["text"],
                  GeoHashedItem.COUNTRY: value["pla"].country,
                  GeoHashedItem.CITY: value["pla"].locality,
                  GeoHashedItem.POSITION: geoFirePoint.data,
                },
              );
            }

            return "blegm";
          }
        },
      );
    }
  }

  sendVerificationEmail(
    String email,
    BuildContext context,
  ) {
    if (AuthProvider.of(context).auth.getCurrentUser().email == email) {
      AuthProvider.of(context).auth.startVerifyingEmail();
    } else {
      AuthProvider.of(context).auth.changeEmailThenVerify(email);
    }

    sendVerifyingEmailNotification(
      AuthProvider.of(context).auth.getCurrentUID(),
      email,
    );

    CommunicationServices().showToast(
      "We have sent you an email with a link to your email address $email. Please tap on that link to confirm. If oyu can't see the email, check your spam folder.",
      Colors.green,
    );
  }

  sendVerifyingEmailNotification(
    String uid,
    String email,
  ) {
    NotificationModel not = NotificationModel.fromData(
      uid,
      "Verify Your Account.",
      "We have sent you an email to your email address $email with a link for you to verify your account. Tap on that link to verify your account and enjoy $capitalizedAppName. If you can't see the email, check your spam folder.",
      DateTime.now(),
    );

    FirebaseFirestore.instance
        .collection(NotificationModel.DIRECTORY)
        .doc(uid)
        .collection(uid)
        .add(
          MapGeneration().generateNotificationMap(
            not,
          ),
        );
  }

  updateFCMToken(String userID, String token) {
    FirebaseDatabase.instance.ref().child(UserModel.FCMTOKENS).update({
      userID: token,
    });
  }

  createNewUser({
    @required String token,
    @required String phoneNumber,
    @required String email,
    @required String uid,
    @required String userName,
    @required List images,
  }) {
    UserModel user = UserModel.fromData(
      phoneNumber: phoneNumber,
      username: userName,
      images: images,
      profilePic: images.isEmpty ? null : images[0],
      email: email,
    );

    sendVerifyingEmailNotification(
      uid,
      email,
    );

    FirebaseFirestore.instance
        .collection(UserModel.DIRECTORY)
        .doc(uid)
        .set(
          MapGeneration().generateUserMap(user),
        )
        .then(
      (value) {
        updateFCMToken(
          uid,
          token,
        );

        updateLastLogin(uid);

        NotificationModel not = NotificationModel.fromData(
          uid,
          "Welcome To $capitalizedAppName",
          "I'd like to cordially, warmly and ..uhmmm *insert some nice warm word* -ly welcome you to $capitalizedAppName. Feel free to explore the stuff here, interact with the community and enjoy the food. I just hope you like it generally. I Spent a lot of time working on it, tryna make it perfect for you. Feel free to provide any feedback, whether positive or negative.\n\n-Simeon.",
          DateTime.now(),
        );

        FirebaseFirestore.instance
            .collection(NotificationModel.DIRECTORY)
            .doc(uid)
            .collection(uid)
            .add(
              MapGeneration().generateNotificationMap(
                not,
              ),
            );
      },
    );
  }

  notifyAboutLogin(
    String uid,
  ) {
    NotificationModel not = NotificationModel.fromData(
      uid,
      "New Login",
      "Your account has just been logged-in in the $capitalizedAppName app.",
      DateTime.now(),
    );

    FirebaseFirestore.instance
        .collection(NotificationModel.DIRECTORY)
        .doc(uid)
        .collection(uid)
        .add(
          MapGeneration().generateNotificationMap(
            not,
          ),
        );
  }

  updateLastLogin(String uid) {
    FirebaseDatabase.instance
        .ref()
        .child(UserModel.LASTLOGINTIME)
        .child(uid)
        .update({
      DateTime.now().millisecondsSinceEpoch.toString(): true,
    });
  }

  updateLastLogout(String uid) {
    FirebaseDatabase.instance
        .ref()
        .child(UserModel.LASTLOGOUTTIME)
        .child(uid)
        .update({
      DateTime.now().millisecondsSinceEpoch.toString(): true,
    });
  }
}
