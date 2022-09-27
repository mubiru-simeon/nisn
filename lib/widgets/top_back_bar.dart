import 'package:flutter/material.dart';

import '../services/navigation.dart';
import 'custom_sized_box.dart';


class BackBar extends StatelessWidget {
  final String text;
  final Function onPressed;
  final List<Widget> actions;
  final bool showBackButton;
  final IconData icon;

  BackBar({
    Key key,
    @required this.icon,
    @required this.onPressed,
    @required this.text,
    this.actions,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSizedBox(
          sbSize: SBSize.smallest,
          height: true,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              showBackButton
                  ? IconButton(
                      icon: Icon(
                        icon ?? Icons.arrow_back_ios_rounded,
                      ),
                      onPressed: onPressed ??
                          () {
                            NavigationService().pop();
                          },
                    )
                  : CustomSizedBox(
                      sbSize: SBSize.small,
                      height: false,
                    ),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (actions != null && actions.isNotEmpty)
                Row(
                  children: actions.map((e) {
                    return e;
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
