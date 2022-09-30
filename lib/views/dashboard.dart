import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nisn/services/ui_services.dart';
import 'package:nisn/views/data_view.dart';
import 'package:nisn/views/info_view.dart';
import 'package:nisn/views/earth_view.dart';
import 'package:nisn/widgets/custom_drawer.dart';
import 'package:nisn/widgets/submit_data_bottom_sheet.dart';

class Dashboard extends StatefulWidget {
  Dashboard({
    Key key,
  }) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  List<Widget> pages = [];
  PageController controller = PageController(
    initialPage: 2
  );
  int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    pages = [
      InfoView(),
      DataView(),
      EarthView(),
      Container(),
    ];

    return Scaffold(
      drawer: CustomDrawer(),
      body: PageView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        children: pages,
        onPageChanged: (v) {
          setState(() {
            currentIndex = v;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: handleTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.info,
            ),
            label: "Info",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.data_array,
            ),
            label: "Raw Data",
          ), BottomNavigationBarItem(
            icon: Icon(
              FontAwesomeIcons.earthAmericas,
            ),
            label: "Earth",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
            ),
            label: "Add",
          ),
        ],
      ),
    );
  }

  handleTap(int v) {
    if (v != 3) {
      controller.jumpToPage(v);
    } else {
      UIServices().showDatSheet(
        SubmitDataBottomSheet(),
        true,
        context,
      );
    }
  }
}
