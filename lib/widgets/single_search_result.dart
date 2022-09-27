import 'package:nisn/widgets/single_previous_item.dart';
import 'package:flutter/material.dart';

class SingleSearchResult extends StatelessWidget {
  final String type;
  final bool sized;
  final bool sensitive;
  final List allowedTypes;
  final bool selectable;
  final String thingID;
  final Function onTap;
  final bool fullWidth;
  final Map thing;
  final bool horizontal;
  final bool list;
  final bool selected;
  final String searchedText;
  const SingleSearchResult({
    Key key,
    @required this.thing,
    @required this.selectable,
    @required this.fullWidth,
    this.sized,
    this.sensitive = false,
    this.allowedTypes,
    @required this.type,
    this.thingID,
    @required this.onTap,
    @required this.horizontal,
    @required this.selected,
    @required this.searchedText,
    @required this.list,
  }) : super(key: key);

  final String objectID = "objectID";

  @override
  Widget build(BuildContext context) {
    final String usableThingID = thingID ?? thing[objectID];

    return sensitive && !allowedTypes.contains(type)
        ? Container()
        : SinglePreviousItem(
            selectable: selectable,
            selected: selected,
            horizontal: horizontal,
            searchedText: searchedText,
            list: list,
            sized: sized,
            onTap: onTap,
            sensitive: sensitive,
            usableThingID: usableThingID,
            type: type,
          );
  }
}
