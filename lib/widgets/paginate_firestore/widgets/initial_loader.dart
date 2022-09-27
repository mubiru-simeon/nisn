import 'package:flutter/material.dart';
import 'package:nisn/widgets/loading_widget.dart';

class InitialLoader extends StatelessWidget {
  const InitialLoader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingWidget(),
    );
  }
}
