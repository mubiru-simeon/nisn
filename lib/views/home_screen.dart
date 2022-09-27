import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../constants/basic.dart';
import '../models/user.dart';
import '../services/auth_provider_widget.dart';
import '../services/communications.dart';
import '../services/navigation.dart';
import '../widgets/custom_dialog_box.dart';
import '../widgets/custom_drawer.dart';
import 'about_us_view.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime currentBackPressTime;
  TabController controller;
  Box box;
  List modes;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      CommunicationServices().showSnackBar(
        "Press back once more to exit $capitalizedAppName",
        context,
      );

      return Future.value(false);
    }

    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();
    box = Hive.box(UserModel.HIVEBOXNAME);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text("fdff"),
            actions: [
              IconButton(
                onPressed: () {
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
                icon: Icon(
                  Icons.logout,
                ),
              ),
              IconButton(
                onPressed: () {
                  NavigationService().push(
                    AboutUs(),
                  );
                },
                icon: Icon(
                  Icons.info,
                ),
              ),
            ],
          ),
          drawer: CustomDrawer(),
          body: Container()),
    );
  }
}
