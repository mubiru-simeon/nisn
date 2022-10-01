import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nisn/constants/constants.dart';
import 'package:nisn/models/nisn_data.dart';
import 'package:nisn/views/no_data_found_view.dart';
import 'package:nisn/widgets/custom_app_bar.dart';
import 'package:nisn/widgets/informational_box.dart';
import 'package:nisn/widgets/paginate_firestore/paginate_firestore.dart';

import '../services/date_service.dart';
import '../services/text_service.dart';

class DataView extends StatefulWidget {
  DataView({
    Key key,
  }) : super(key: key);

  @override
  State<DataView> createState() => _DataViewState();
}

class _DataViewState extends State<DataView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return PaginateFirestore(
      isLive: true,
      header: SliverList(
        delegate: SliverChildListDelegate([
          CustomAppBar(
            title: "Ionosphere Data",
          ),
          InformationalBox(
            visible: true,
            onClose: null,
            message:
                "This data is updated with real time values from amateur Ham Radio enthusiasts all over th world",
          ),
        ]),
      ),
      onEmpty: NoDataFound(
        text: "No Records Yet",
        doSthText: "Tap here and be the first to submit data",
      ),
      itemBuilderType: PaginateBuilderType.listView,
      itemsPerPage: 5,
      itemBuilder: (context, snapshot, index) {
        NisnData nisnData = NisnData.fromSnapshot(snapshot[index]);

        return GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 5,
            ),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: standardBorderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Latitude: ${nisnData.lat}",
                ),
                Text(
                  "Longitude: ${nisnData.long}",
                ),
                Text(
                  "Altitude: ${nisnData.alt}",
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Geo-X: ${nisnData.geox}",
                ),
                Text(
                  "Geo-Y: ${nisnData.geoy}",
                ),
                Text(
                  "Geo-Z: ${nisnData.geoz}",
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Geo-VX: ${nisnData.geovx}",
                ),
                Text(
                  "Geo-VY: ${nisnData.geovy}",
                ),
                Text(
                  "Geo-VZ: ${nisnData.geovz}",
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "Electron Density (e/m^3): ${TextService().putCommas((nisnData.electronDensity * 100000000000).toStringAsFixed(2))}"),
                Text("Submitted on ${DateService().dateFromMilliseconds(
                  nisnData.date,
                )}")
              ],
            ),
          ),
        );
      },
      query: FirebaseFirestore.instance
          .collection(NisnData.DIRECTORY)
          .orderBy(NisnData.TIME, descending: true),
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
