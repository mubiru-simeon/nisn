import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants/ui.dart';


class LoadingWidget extends StatelessWidget {
  final Color color;
  final double size;
  const LoadingWidget({
    Key key,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(8),
        child: SpinKitWave(
          size: size ?? 20,
          color: color ?? primaryColor,
        ),
      ),
    );
  }
}
