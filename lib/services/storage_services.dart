import 'package:firebase_database/firebase_database.dart';

import '../models/user.dart';

class StorageServices {
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
