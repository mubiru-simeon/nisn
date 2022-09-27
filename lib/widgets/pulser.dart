import 'dart:async';

import 'package:flutter/material.dart';

class Pulser extends StatefulWidget {
  final int duration;
  final Widget child;

  const Pulser({
    Key key,
    @required this.child,
    this.duration = 800,
  }) : super(key: key);

  @override
  State<Pulser> createState() => _PulserState();
}

class _PulserState extends State<Pulser> {
  bool visible = true;

  @override
  void initState() {
    super.initState();
    startPulse();
  }

  startPulse() {
    Timer(Duration(milliseconds: widget.duration), () {
      if (mounted) {
        setState(() {
          visible = !visible;
        });
      }

      startPulse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: Duration(
        milliseconds: widget.duration,
      ),
      child: widget.child,
    );
  }
}
