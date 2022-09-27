import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nisn/constants/images.dart';

import '../constants/ui.dart';
import '../services/ui_services.dart';
import '../widgets/custom_sized_box.dart';

class NotSignedInView extends StatefulWidget {
  NotSignedInView({
    Key key,
  }) : super(key: key);

  @override
  State<NotSignedInView> createState() => _NotSignedInViewState();
}

class _NotSignedInViewState extends State<NotSignedInView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                noDataFoundSvg,
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              CustomSizedBox(
                sbSize: SBSize.small,
                height: true,
              ),
              Text(
                "This page is only accessible when logged in. Please Sign in.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              CustomSizedBox(
                sbSize: SBSize.small,
                height: true,
              ),
              GestureDetector(
                onTap: () async {
                  UIServices().showLoginSheet(
                    AuthFormType.signIn,
                    (v) {},
                    context,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: standardBorderRadius,
                      border: Border.all(width: 1)),
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 16,
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
