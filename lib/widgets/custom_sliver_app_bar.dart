import 'package:flutter/material.dart';
import 'package:nisn/services/navigation.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final double height;
  final Color titleColor;
  final bool pushed;
  final List<Widget> actions;
  final FlexibleSpaceBar flexibleSpaceBar;
  const CustomSliverAppBar({
    Key key,
    this.title,
    this.flexibleSpaceBar,
    this.pushed = true,
    this.height = 0,
    this.actions,
    this.titleColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).canvasColor,
      snap: false,
      flexibleSpace: flexibleSpaceBar,
      floating: false,
      expandedHeight: height,
      title: title != null
          ? Text(
              title,
              style: TextStyle(
                color: titleColor,
              ),
            )
          : null,
      leading: GestureDetector(
        onTap: () {
          if (pushed) {
            NavigationService().pop();
          } else {
            Scaffold.of(context).openDrawer();
          }
        },
        child: Icon(
          pushed ? Icons.arrow_back_ios : Icons.menu,
          color: Colors.grey,
        ),
      ),
      actions: actions != null && actions.isNotEmpty ? actions : [],
    );
  }
}
