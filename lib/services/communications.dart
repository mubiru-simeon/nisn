
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommunicationServices {
  showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }

  showSnackBar(String message, BuildContext context,
      {Function whatToDo, String buttonText, SnackBarBehavior behavior}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: behavior,
        action: whatToDo == null
            ? null
            : SnackBarAction(
                label: buttonText,
                onPressed: whatToDo,
              ),
      ),
    );
  }
}
