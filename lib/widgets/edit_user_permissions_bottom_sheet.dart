import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/thing_type.dart';
import '../models/user.dart';
import '../services/auth_provider_widget.dart';
import 'loading_widget.dart';
import 'row_selector.dart';
import 'top_back_bar.dart';

class EditUserPermissionsBottomSheet extends StatefulWidget {
  final UserModel user;
  EditUserPermissionsBottomSheet({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  State<EditUserPermissionsBottomSheet> createState() =>
      _EditUserPermissionsBottomSheetState();
}

class _EditUserPermissionsBottomSheetState
    extends State<EditUserPermissionsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    String path;
    widget.user.email
        .split(RegExp(
      r"[.,@]",
    ))
        .forEach(
      (element) {
        if (path != null) {
          path = "$path/${element.trim().toLowerCase()}";
        } else {
          path = element.trim().toLowerCase();
        }
      },
    );

    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Edit User Permissions",
        ),
        Expanded(
          child: StreamBuilder(
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingWidget();
              } else {
                dynamic data = snapshot.data.snapshot.value ?? {};

                bool admin = data[ThingType.ADMIN] != null ?? false;
                bool radiologist = data[ThingType.RADIOLOGIST] != null ?? false;
               
                return Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          Expanded(
                            child: RowSelector(
                              selected: admin,
                              text: "Admin",
                              onTap: () {
                                handleTap(
                                  admin,
                                  ThingType.ADMIN,
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: RowSelector(
                              selected: radiologist,
                              text: "Amateur Radio Specialist",
                              onTap: () {
                                handleTap(
                                  radiologist,
                                  ThingType.RADIOLOGIST,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
            stream: FirebaseDatabase.instance
                .ref()
                .child(UserModel.ACCOUNTTYPES)
                .child(path)
                .onValue,
          ),
        )
      ],
    );
  }

  handleTap(
    bool thing,
    String type,
  ) async {
    String path;
    widget.user.email
        .split(RegExp(
      r"[.,@]",
    ))
        .forEach(
      (element) {
        if (path != null) {
          path = "$path/${element.trim().toLowerCase()}";
        } else {
          path = element.trim().toLowerCase();
        }
      },
    );

    if (thing) {
      FirebaseDatabase.instance
          .ref()
          .child(UserModel.ACCOUNTTYPES)
          .child(path)
          .child(type)
          .remove();

      await FirebaseFirestore.instance
          .collection(UserModel.DIRECTORY)
          .doc(widget.user.id)
          .get()
          .then((value) {
        UserModel userModel = UserModel.fromSnapshot(value);

        dynamic pp = userModel.permissionUpdates;

        pp.addAll({
          DateTime.now().millisecondsSinceEpoch.toString(): {
            UserModel.TYPE: type,
            UserModel.MODE: UserModel.REMOVING,
            UserModel.REGISTERER: AuthProvider.of(context).auth.getCurrentUID(),
          }
        });

        FirebaseFirestore.instance
            .collection(UserModel.DIRECTORY)
            .doc(widget.user.id)
            .update({
          type: false,
          UserModel.PERMISSIONUPDATES: pp,
        });
      });
    } else {
      FirebaseDatabase.instance
          .ref()
          .child(UserModel.ACCOUNTTYPES)
          .child(path)
          .child(type)
          .set(
            DateTime.now().millisecondsSinceEpoch,
          );

      await FirebaseFirestore.instance
          .collection(UserModel.DIRECTORY)
          .doc(widget.user.id)
          .get()
          .then((value) {
        UserModel userModel = UserModel.fromSnapshot(value);

        dynamic pp = userModel.permissionUpdates;

        pp.addAll({
          DateTime.now().millisecondsSinceEpoch.toString(): {
            UserModel.TYPE: type,
            "mode": "adding",
            UserModel.REGISTERER: AuthProvider.of(context).auth.getCurrentUID(),
          }
        });

        FirebaseFirestore.instance
            .collection(UserModel.DIRECTORY)
            .doc(widget.user.id)
            .update({
          type: true,
          UserModel.PERMISSIONUPDATES: pp,
        });
      });
    }
  }
}
