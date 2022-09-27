import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nisn/constants/images.dart';
import 'package:nisn/constants/ui.dart';
import 'package:nisn/models/user.dart';
import 'package:nisn/widgets/loading_widget.dart';
import 'package:nisn/services/ui_services.dart';

import 'custom_sized_box.dart';
import 'deleted_item.dart';

class SingleUser extends StatelessWidget {
  final String userID;
  final UserModel user;
  final bool mini;
  final Function onTap;
  const SingleUser({
    Key key,
    @required this.user,
    @required this.userID,
    this.mini = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return user == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(UserModel.DIRECTORY)
                .doc(userID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() == null) {
                  return DeletedItem(
                    what: "User",
                    thingID: userID,
                  );
                } else {
                  UserModel model = UserModel.fromSnapshot(
                    snapshot.data,
                  );

                  return body(
                    model,
                    context,
                  );
                }
              } else {
                return LoadingWidget();
              }
            })
        : body(
            user,
            context,
          );
  }

  body(
    UserModel user,
    BuildContext context,
  ) {
    return mini
        ? mainBody(user)
        : Container(
            margin: EdgeInsets.all(6),
            child: GestureDetector(
              onTap: () {
                if (onTap != null) {
                  onTap();
                } else {}
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: standardBorderRadius,
                ),
                padding: EdgeInsets.all(3),
                child: Column(
                  children: [
                    Material(
                      elevation: standardElevation,
                      borderRadius: standardBorderRadius,
                      child: ClipRRect(
                        borderRadius: standardBorderRadius,
                        child: mainBody(user),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  mainBody(UserModel user) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: UIServices().getImageProvider(
                  user.profilePic ?? defaultUserPic,
                ),
              ),
              CustomSizedBox(
                sbSize: SBSize.small,
                height: false,
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user.email != null)
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (user.phoneNumber != null)
                      Text(
                        user.phoneNumber,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
