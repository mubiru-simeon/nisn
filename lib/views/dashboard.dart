import 'package:flutter/material.dart';
import 'package:nisn/services/ui_services.dart';
import 'package:nisn/views/data_view.dart';
import 'package:nisn/views/info_view.dart';
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
  PageController controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    pages = [
      InfoView(),
      DataView(),
      Container(),
    ];

    return Scaffold(
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
            label: "Data",
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
    if (v != 2) {
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
