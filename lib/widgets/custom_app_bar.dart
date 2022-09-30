import 'package:flutter/material.dart';
import 'package:nisn/services/navigation.dart';

class CustomAppBar extends StatefulWidget {
  final String title;
  final bool pushed;
  final bool showSearched;

  CustomAppBar({
    Key key,
    @required this.title,
    this.pushed = false,
    this.showSearched = false,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).canvasColor,
      title: widget.title != null
          ? Text(
              widget.title,
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          : null,
      leading: GestureDetector(
        onTap: () {
          if (widget.pushed) {
            NavigationService().pop();
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
        child: Icon(
          widget.pushed ? Icons.arrow_back_ios : Icons.menu,
          color: Colors.grey,
        ),
      ),
      actions: [],
    );
  }
}
