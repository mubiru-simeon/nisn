import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nisn/constants/basic.dart';
import 'package:nisn/views/dashboard.dart';

import '../constants/images.dart';
import '../services/auth_provider_widget.dart';
import '../services/navigation.dart';
import '../widgets/pulser.dart';

class SplashScreenView extends StatefulWidget {
  SplashScreenView({Key key}) : super(key: key);

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  void navigationPage() async {
    NavigationService().pushReplacement(
      Dashboard(),
    );
  }

  startTime() async {
    var duration = Duration(seconds: 3);
    return Timer(duration, navigationPage);
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider.of(context).auth.reloadAccount(context);

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.asset(
                  galaxy,
                  color: Colors.black.withOpacity(0.7),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  Center(
                    child: Pulser(
                      duration: 800,
                      child: Image(
                        width: MediaQuery.of(context).size.width * 0.6,
                        image: AssetImage(
                          logoLight,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    capitalizedAppName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
