import 'package:flutter/material.dart';

class SelectorThingie extends StatelessWidget {
  const SelectorThingie({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.green,
      child: Center(
        child: Icon(
          Icons.done,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }
}
