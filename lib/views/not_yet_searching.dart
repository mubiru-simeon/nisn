import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/constants.dart';
import '../widgets/custom_sized_box.dart';

class NotYetSearchingView extends StatelessWidget {
  final String text;
  NotYetSearchingView({
    Key key,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSizedBox(
          sbSize: SBSize.small,
          height: true,
        ),
        SvgPicture.asset(
          noDataFoundSvg,
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.width * 0.5,
        ),
        CustomSizedBox(
          sbSize: SBSize.normal,
          height: true,
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
