import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nisn/widgets/custom_divider.dart';
import 'package:nisn/widgets/informational_box.dart';
import 'package:nisn/widgets/or_divider.dart';
import 'package:nisn/widgets/proceed_button.dart';
import 'package:nisn/widgets/top_back_bar.dart';

import '../constants/ui.dart';
import '../services/date_service.dart';

class SubmitDataBottomSheet extends StatefulWidget {
  SubmitDataBottomSheet({
    Key key,
  }) : super(key: key);

  @override
  State<SubmitDataBottomSheet> createState() => _SubmitDataBottomSheetState();
}

class _SubmitDataBottomSheetState extends State<SubmitDataBottomSheet> {
  TextEditingController latitude = TextEditingController();
  TextEditingController longitude = TextEditingController();
  TextEditingController altitude = TextEditingController();
  TextEditingController geox = TextEditingController();
  TextEditingController geoy = TextEditingController();
  TextEditingController geoz = TextEditingController();
  TextEditingController geovx = TextEditingController();
  TextEditingController geovy = TextEditingController();
  TextEditingController geovz = TextEditingController();
  TextEditingController electronDensity = TextEditingController();
  List<PlatformFile> quotationDocuments = [];
  DateTime dateOfRecord = DateTime.now();
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Submit some data",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    InformationalBox(
                      visible: true,
                      onClose: null,
                      message:
                          "You can either submit an individual record or a csv of records that the system can auto-parse and upload.",
                    ),
                    CustomDivider(),
                    ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.document_scanner,
                        ),
                      ),
                      onTap: () async {
                        final rr = await FilePicker.platform.pickFiles(
                          withData: true,
                          allowMultiple: true,
                        );

                        if (rr != null) {
                          setState(() {
                            for (var e in rr.files) {
                              quotationDocuments.add(e);
                            }
                          });
                        }
                      },
                      subtitle: quotationDocuments.isEmpty
                          ? Text("Tap here to select the csv document")
                          : Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "You can still select a different document. Just tap here.",
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  height: 80,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: quotationDocuments.map(
                                        (e) {
                                          return Stack(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                height: double.infinity,
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 2,
                                                ),
                                                alignment:
                                                    Alignment.bottomCenter,
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      standardBorderRadius,
                                                  color: primaryColor,
                                                ),
                                                child: Text(
                                                  e.name
                                                      .toString()
                                                      .toUpperCase(),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      quotationDocuments
                                                          .remove(e);
                                                    });
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor: Colors.red,
                                                    child: Icon(
                                                      Icons.close,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                      title: Text(
                        quotationDocuments.isNotEmpty
                            ? "${quotationDocuments.first.name} ${quotationDocuments.length > 1 ? "and other docs" : ""}"
                            : "The CSV File",
                      ),
                    ),
                    CustomDivider(),
                    SizedBox(
                      height: 10,
                    ),
                    OrDivider(),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: latitude,
                      decoration: InputDecoration(
                        hintText: "Latitude",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: longitude,
                      decoration: InputDecoration(
                        hintText: "Longitude",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: altitude,
                      decoration: InputDecoration(
                        hintText: "Altitude",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: geox,
                      decoration: InputDecoration(
                        hintText: "Geo-X",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: geoy,
                      decoration: InputDecoration(
                        hintText: "Geo-Y",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: geoz,
                      decoration: InputDecoration(
                        hintText: "Geo-Z",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: geovx,
                      decoration: InputDecoration(
                        hintText: "Geo-VX",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: geovy,
                      decoration: InputDecoration(
                        hintText: "Geo-VY",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: geovz,
                      decoration: InputDecoration(
                        hintText: "Geo-VZ",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: electronDensity,
                      decoration: InputDecoration(
                        hintText: "Electron Density",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomDivider(),
                    ListTile(
                      onTap: () async {
                        DateTime now = await showDatePicker(
                          context: context,
                          initialDate: dateOfRecord ?? DateTime.now(),
                          firstDate: DateTime(1800),
                          lastDate: DateTime.now().add(
                            Duration(
                              days: 3650,
                            ),
                          ),
                        );

                        if (now != null) {
                          TimeOfDay nowTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (nowTime != null) {
                            setState(() {
                              DateTime dd = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                nowTime.hour,
                                nowTime.minute,
                              );

                              dateOfRecord = dd;
                            });
                          }
                        }
                      },
                      title: Text(
                        dateOfRecord != null
                            ? "Date of the record: $dateOfRecord"
                            : "Date of the record",
                      ),
                      subtitle: dateOfRecord != null
                          ? Text("You can tap here to edit the date")
                          : Text(
                              "Tap here to select when this record was recorded",
                            ),
                    ),
                    CustomDivider(),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Wrap(children: [
        ProceedButton(
          processable: true,
          processing: processing,
          onTap: () {},
          text: "Upload",
        )
      ]),
    );
  }
}
