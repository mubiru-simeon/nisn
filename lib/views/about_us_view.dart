import 'package:flutter/material.dart';
import 'package:nisn/services/text_service.dart';

import '../constants/basic.dart';
import '../constants/images.dart';
import '../constants/ui.dart';
import '../widgets/custom_sized_box.dart';
import '../widgets/top_back_bar.dart';

class AboutUs extends StatefulWidget {
  AboutUs({
    Key key,
  }) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "About $capitalizedAppName",
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image(
                                  height: 100,
                                  image: AssetImage(
                                    logoDark,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        appName.capitalizeFirstOfEach
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: primaryColor,
                                          fontSize: 25,
                                        ),
                                      ),
                                      Text(
                                        ".",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Version $versionNumber",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      CustomSizedBox(
                        sbSize: SBSize.small,
                        height: true,
                      ),
                      Text(
                        appCatchPhrase,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      /*  CustomSizedBox(
                        sbSize: SBSize.normal,
                        height: true,
                      ),
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(
                          dorxLogo,
                        ),
                      ),
                      CustomSizedBox(
                        sbSize: SBSize.normal,
                        height: true,
                      ),
                      CustomDivider(),
                      ListTile(
                        onTap: () {
                          launchUrl(
                            Uri.parse("tel:$dorxPhoneNumber"),
                          );
                        },
                        leading: Icon(
                          Icons.info,
                        ),
                        title: Text(
                          "This app was custom designed and built for Maisha MEdical Services by the lovely team at Dorx Code Labs. Tap here to contact us for any apps, websites etc.",
                        ),
                      ),
                      CustomDivider(),
                      CustomSizedBox(
                        sbSize: SBSize.large,
                        height: true,
                      ), */
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
