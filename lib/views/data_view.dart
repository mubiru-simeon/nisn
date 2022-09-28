import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nisn/models/nisn_data.dart';
import 'package:nisn/views/no_data_found_view.dart';
import 'package:nisn/widgets/custom_sliver_app_bar.dart';
import 'package:nisn/widgets/paginate_firestore/paginate_firestore.dart';

class DataView extends StatefulWidget {
  DataView({
    Key key,
  }) : super(key: key);

  @override
  State<DataView> createState() => _DataViewState();
}

class _DataViewState extends State<DataView> {
  @override
  Widget build(BuildContext context) {
    return PaginateFirestore(
      isLive: true,
      header: CustomSliverAppBar(title: "Ionosphere Data", pushed: false, ),
      onEmpty: NoDataFound(
        text: "No Records Yet",
        doSthText: "Tap here and be the first to submit data",
      ),
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, snapshot, index) {
        NisnData nisnData = NisnData.fromSnapshot(snapshot[index]);

        return Container();
      },
      query: FirebaseFirestore.instance
          .collection(NisnData.DIRECTORY)
          .orderBy(NisnData.TIME, descending: true),
    );
  }
}
