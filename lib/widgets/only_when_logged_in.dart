import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_provider_widget.dart';
import '../views/not_signed_in.dart';
import 'loading_widget.dart';

class OnlyWhenLoggedIn extends StatefulWidget {
  final Function doOnceSignedIn;
  final Widget notSignedIn;
  final Widget Function(String) signedInBuilder;
  final Widget loadingView;
  OnlyWhenLoggedIn({
    Key key,
    this.doOnceSignedIn,
    this.loadingView,
    this.notSignedIn,
    this.signedInBuilder,
  }) : super(key: key);

  @override
  State<OnlyWhenLoggedIn> createState() => _OnlyWhenLoggedInState();
}

class _OnlyWhenLoggedInState extends State<OnlyWhenLoggedIn> {
  User user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: AuthProvider.of(context).auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            if (widget.doOnceSignedIn != null) {
              widget.doOnceSignedIn();
            }

            return widget.signedInBuilder(
              AuthProvider.of(context).auth.getCurrentUID(),
            );
          } else {
            return widget.notSignedIn ?? NotSignedInView();
          }
        } else {
          return widget.loadingView ?? LoadingWidget();
        }
      },
    );
  }
}
