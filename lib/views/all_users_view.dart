
import 'package:nisn/constants/ui.dart';
import 'package:nisn/services/communications.dart';
import 'package:nisn/services/ui_services.dart';
import 'package:nisn/views/no_data_found_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/edit_user_permissions_bottom_sheet.dart';
import '../widgets/paginate_firestore/paginate_firestore.dart';
import '../widgets/selector.dart';
import '../widgets/single_big_button.dart';
import '../widgets/single_user.dart';
import '../widgets/top_back_bar.dart';

class AllUsersView extends StatefulWidget {
  final bool returning;
  final String mode;
  AllUsersView({
    Key key,
    this.returning = false,
    this.mode,
  }) : super(key: key);

  @override
  State<AllUsersView> createState() => _AllUsersViewState();
}

class _AllUsersViewState extends State<AllUsersView> {
  String selectedUser;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mainView(),
       
      ],
    );
  }

  Widget mainView() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "All Users",
            ),
            Expanded(
              child: PaginateFirestore(
                
                isLive: true,
                onEmpty: NoDataFound(
                  text: "No Users Yet. Tap the add button to add",
                ),
                itemsPerPage: 4,
                itemBuilder: (
                  context,
                  snapshot,
                  index,
                ) {
                  UserModel userModel = UserModel.fromSnapshot(snapshot[index]);

                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: standardBorderRadius,
                        ),
                        child: Column(
                          children: [
                            SingleUser(
                              user: userModel,
                              onTap: () {
                                if (widget.returning) {
                                  setState(() {
                                    selectedUser = userModel.id;
                                  });
                                } else {}
                              },
                              userID: userModel.id,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: SingleBigButton(
                                    color: primaryColor,
                                    onPressed: () {
                                      UIServices().showDatSheet(
                                        EditUserPermissionsBottomSheet(
                                          user: userModel,
                                        ),
                                        true,
                                        context,
                                      );
                                    },
                                    text: "Edit Permissions",
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      if (selectedUser == userModel.id) SelectorThingie(),
                    ],
                  );
                },
                query: widget.mode == null
                    ? FirebaseFirestore.instance.collection(UserModel.DIRECTORY)
                    : FirebaseFirestore.instance
                        .collection(UserModel.DIRECTORY)
                        .where(
                          widget.mode,
                          isEqualTo: true,
                        ),
                itemBuilderType: PaginateBuilderType.listView,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: widget.returning
          ? FloatingActionButton(
              onPressed: () {
                finish();
              },
              child: Icon(
                Icons.done,
              ),
            )
          : null,
    );
  }

  finish() {
    if (selectedUser == null) {
      CommunicationServices().showToast(
        "Please select a user",
        Colors.red,
      );
    } else {
      Navigator.of(context).pop(selectedUser);
    }
  }
}
