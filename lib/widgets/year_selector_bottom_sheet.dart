import 'package:flutter/material.dart';
import 'package:nisn/services/communications.dart';
import 'package:nisn/widgets/single_select_tile.dart';
import 'package:nisn/widgets/top_back_bar.dart';

class YearSelectorBottomSheet extends StatefulWidget {
  YearSelectorBottomSheet({
    Key key,
  }) : super(key: key);

  @override
  State<YearSelectorBottomSheet> createState() =>
      _YearSelectorBottomSheetState();
}

class _YearSelectorBottomSheetState extends State<YearSelectorBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Select a year",
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                2022,
                2021,
                2020,
                2019,
                2018,
                2017,
                2016,
                2015,
                2014,
                2013,
                2012,
                2011,
                2010,
                2009,
                2008,
                2007,
                2006,
                2005,
                2004,
                2003,
                2002,
                2001,
                2000,
                1999,
              ]
                  .map(
                    (e) => SingleSelectTile(
                      onTap: () {
                        Navigator.of(context).pop(e);

                        CommunicationServices().showToast(
                          "Fetching records for the year $e",
                          Colors.green,
                        );
                      },
                      selected: false,
                      asset: null,
                      text: e.toString(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
