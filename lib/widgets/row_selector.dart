import 'package:nisn/services/ui_services.dart';
import 'package:flutter/material.dart';
import 'package:nisn/constants/ui.dart';

class RowSelector extends StatelessWidget {
  final String text;
  final Color selectedColor;
  final Widget child;
  final bool selected;
  final String image;
  final Function onTap;
  RowSelector({
    Key key,
    @required this.onTap,
    @required this.selected,
    this.text,
    this.child,
    this.image,
    this.selectedColor = primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: selected ? selectedColor : null,
          borderRadius: standardBorderRadius,
          image: selected
              ? null
              : UIServices().decorationImage(
                  image,
                  true,
                ),
          border: Border.all(
            width: 2,
            color: selected ? selectedColor : Colors.grey,
          ),
        ),
        padding: EdgeInsets.only(
          left: 6,
          right: 6,
          bottom: 6,
          top: 6,
        ),
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: 2,
          right: 2,
        ),
        child: Center(
          child: child ??
              Text(
                text ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected || image != null ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
    );
  }
}
