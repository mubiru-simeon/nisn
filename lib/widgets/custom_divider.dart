import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double width;
  CustomDivider({
    Key key,
    this.height,
    this.width,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.grey,
      height: 1,
      padding: height != null ? EdgeInsets.symmetric(vertical: 20) : null,
      width: /* width != null ? width : */ MediaQuery.of(context).size.width,
    );
  }
}
