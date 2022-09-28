import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../services/navigation.dart';
import '../services/ui_services.dart';
import 'custom_sized_box.dart';

class CustomDialogBox extends StatefulWidget {
  final String bodyText;
  final bool showSignInButton;
  final bool showOtherButton;
  final String buttonText;
  final List<String> bullets;
  final Function onButtonTap;
  final String afterBullets;
  final String signInButtonText;
  final Widget child;
  final Function(String) onLoggedIn;

  CustomDialogBox({
    Key key,
    this.showSignInButton = false,
    @required this.bodyText,
    @required this.buttonText,
    this.signInButtonText = "Sign In",
    this.onLoggedIn,
    @required this.onButtonTap,
    @required this.showOtherButton,
    this.afterBullets,
    this.bullets,
    this.child,
  }) : super(key: key);

  @override
  State<CustomDialogBox> createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      NavigationService().pop();
                    },
                    child: CircleAvatar(
                      child: Icon(
                        Icons.close,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    width: 80,
                    height: 80,
                    image: AssetImage(
                      logoDark,
                    ),
                  ),
                  CustomSizedBox(
                    sbSize: SBSize.small,
                    height: false,
                  ),
                  Text(
                    capitalizedAppName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CustomSizedBox(
                sbSize: SBSize.small,
                height: true,
              ),
              if (widget.child != null) widget.child,
              if (widget.child == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.bodyText ??
                          "You need to Sign in or create an account to use this feature. Press the button below to Sign in.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    CustomSizedBox(
                      sbSize: SBSize.smallest,
                      height: true,
                    ),
                    if (widget.bullets != null && widget.bullets.isNotEmpty)
                      Column(
                        children: widget.bullets.map((e) {
                          return Padding(
                            padding: EdgeInsets.all(3),
                            child: Row(
                              children: [
                                Text("-"),
                                CustomSizedBox(
                                  sbSize: SBSize.smallest,
                                  height: false,
                                ),
                                Expanded(
                                  child: Text(
                                    e,
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    CustomSizedBox(
                      sbSize: SBSize.smallest,
                      height: true,
                    ),
                    if (widget.afterBullets != null)
                      Text(
                        widget.afterBullets,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    CustomSizedBox(
                      sbSize: SBSize.smallest,
                      height: true,
                    ),
                  ],
                ),
              if (widget.child == null)
                CustomSizedBox(
                  sbSize: SBSize.smallest,
                  height: true,
                ),
              if (widget.child == null)
                if (widget.showSignInButton)
                  InkWell(
                    onTap: () {
                      NavigationService().pop();

                      UIServices().showLoginSheet(
                        AuthFormType.signUp,
                        (v) {
                          if (widget.onLoggedIn != null) {
                            widget.onLoggedIn(v);
                          }
                        },
                        context,
                      );
                    },
                    child: Material(
                      borderRadius: standardBorderRadius,
                      elevation: standardElevation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: standardBorderRadius,
                        ),
                        child: Text(
                          widget.signInButtonText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
              CustomSizedBox(
                sbSize: SBSize.small,
                height: true,
              ),
              if (widget.child == null)
                if (widget.showOtherButton)
                  InkWell(
                    onTap: () async {
                      NavigationService().pop();

                      widget.onButtonTap();
                    },
                    child: Material(
                      borderRadius: standardBorderRadius,
                      elevation: standardElevation,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: standardBorderRadius,
                        ),
                        child: Text(
                          widget.buttonText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              if (widget.child == null)
                if (widget.showSignInButton)
                  InkWell(
                    onTap: () {
                      NavigationService().pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 10,
                      ),
                      child: Text(
                        "Maybe Later",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
