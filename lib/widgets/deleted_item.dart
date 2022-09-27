import 'package:flutter/material.dart';
import 'package:nisn/services/text_service.dart';

import '../constants/ui.dart';

class DeletedItem extends StatelessWidget {
  final String what;
  final String thingID;
  const DeletedItem({
    Key key,
    @required this.what,
    @required this.thingID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: standardBorderRadius,
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
      ),
      padding: EdgeInsets.all(15),
      child: Center(
        child: Text(
          "${what.capitalizeFirstOfEach} data not available.",
        ),
      ),
    );
  }
}
