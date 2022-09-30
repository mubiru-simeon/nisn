import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:nisn/views/about_us_view.dart';
import '../constants/constants.dart';
import '../models/user.dart';
import '../services/auth_provider_widget.dart';
import '../services/navigation.dart';
import '../views/all_users_view.dart';
import 'custom_dialog_box.dart';
import 'custom_sized_box.dart';
import 'single_image.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({
    Key key,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box(UserModel.HIVEBOXNAME);
  }

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          Image.asset(
                            galaxy,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: double.infinity,
                            color: Colors.black.withOpacity(0.7),
                            colorBlendMode: BlendMode.darken,
                          ),
                          Center(
                            child: SingleImage(
                              height: 100,
                              image: logoLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      capitalizedAppName.toString().toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    singleDrawerItem(
                      label: "All Users",
                      onTap: () {
                        NavigationService().push(
                          AllUsersView(),
                        );
                      },
                      icon: FontAwesomeIcons.user,
                    ),
                    singleDrawerItem(
                      label: "About Us",
                      onTap: () {
                        NavigationService().push(
                          AboutUs(),
                        );
                      },
                      icon: FontAwesomeIcons.info,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CustomDialogBox(
                      bodyText:
                          "Do you really want to log out? We'll be sad to see you go.",
                      buttonText: "Log out",
                      onButtonTap: () {
                        box.clear();
                        AuthProvider.of(context).auth.signOut();
                      },

                      showOtherButton: true,
                    );
                  },
                );
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Log Out",
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.logout,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  singleDrawerItem({
    @required String label,
    String image,
    @required Function onTap,
    @required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                image == null
                    ? Icon(
                        icon,
                        color: primaryColor,
                      )
                    : CircleAvatar(
                        child: SingleImage(
                          image: image,
                        ),
                      ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: false,
                ),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 5,
          )
        ],
      ),
    );
  }
}
