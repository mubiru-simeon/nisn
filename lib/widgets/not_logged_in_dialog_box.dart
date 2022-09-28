import 'package:flutter/material.dart';

import 'custom_dialog_box.dart';

class NotLoggedInDialogBox extends StatelessWidget {
  final Function(String) onLoggedIn;
  final String text;
  const NotLoggedInDialogBox({
    Key key,
    @required this.onLoggedIn,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDialogBox(
      showSignInButton: true,
      bodyText: text,
      onLoggedIn: onLoggedIn,
      buttonText: null,
      onButtonTap: null,
      showOtherButton: false,
    );
  }
}
