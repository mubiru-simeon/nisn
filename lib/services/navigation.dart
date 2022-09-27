import 'package:flutter/material.dart';

import '../main.dart';

class NavigationService {
  Future<dynamic> push(
    Widget page,
  ) {
    if (page != null) {
      return navigatorKey.currentState.push(
        MaterialPageRoute(
          builder: (context) => page,
        ),
      );
    } else {
      return null;
    }
  }

  popCount(
    int count,
    BuildContext context,
  ) {
    int ct = 0;

    Navigator.of(context).popUntil((route) {
      return ct++ == count;
    });
  }

  popToFirst(
    BuildContext context,
  ) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  void pushReplacement(
    Widget page,
  ) {
    if (page != null) {
      navigatorKey.currentState.pushReplacement(
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  void pop() {
    navigatorKey.currentState.pop();
  }
}
