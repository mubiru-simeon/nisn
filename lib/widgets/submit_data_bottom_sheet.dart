import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nisn/models/nisn_data.dart';
import 'package:nisn/services/auth_provider_widget.dart';
import 'package:nisn/services/communications.dart';
import 'package:nisn/services/navigation.dart';
import 'package:nisn/widgets/custom_divider.dart';
import 'package:nisn/widgets/informational_box.dart';
import 'package:nisn/widgets/not_logged_in_dialog_box.dart';
import 'package:nisn/widgets/or_divider.dart';
import 'package:nisn/widgets/proceed_button.dart';
import 'package:nisn/widgets/top_back_bar.dart';

import '../constants/ui.dart';
import '../services/storage_services.dart';

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
  TextEditingController altitudeController = TextEditingController();
  TextEditingController geox = TextEditingController();
  TextEditingController geoy = TextEditingController();
  TextEditingController geoz = TextEditingController();
  TextEditingController geovx = TextEditingController();
  TextEditingController geovy = TextEditingController();
  TextEditingController geovz = TextEditingController();
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
                            type: FileType.custom,
                            allowedExtensions: ["csv"]);

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
                      controller: altitudeController,
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
          onTap: () async {
            if (quotationDocuments.isNotEmpty) {
              if (AuthProvider.of(context).auth.isSignedIn()) {
                upload();
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return NotLoggedInDialogBox(
                      onLoggedIn: (v) {
                        upload();
                      },
                    );
                  },
                );
              }
            } else {
              if (latitude.text.trim().isEmpty) {
                CommunicationServices().showToast(
                  "Please provide a latitude",
                  Colors.red,
                );
              } else {
                if (longitude.text.trim().isEmpty) {
                  CommunicationServices().showToast(
                    "Please provide a longitude",
                    Colors.red,
                  );
                } else {
                  if (altitudeController.text.trim().isEmpty) {
                    CommunicationServices().showToast(
                      "Please provide an altitude",
                      Colors.red,
                    );
                  } else {
                    if (geox.text.trim().isEmpty) {
                      CommunicationServices().showToast(
                        "Please provide a geo-x",
                        Colors.red,
                      );
                    } else {
                      if (geoy.text.trim().isEmpty) {
                        CommunicationServices().showToast(
                          "Please provide a geo-y",
                          Colors.red,
                        );
                      } else {
                        if (geovx.text.trim().isEmpty) {
                          CommunicationServices().showToast(
                            "Please provide a geo-vx",
                            Colors.red,
                          );
                        } else {
                          if (geovy.text.trim().isEmpty) {
                            CommunicationServices().showToast(
                              "Please provide a geo-vy",
                              Colors.red,
                            );
                          } else {
                            if (geovz.text.trim().isEmpty) {
                              CommunicationServices().showToast(
                                "Please provide a geo-vz",
                                Colors.red,
                              );
                            } else {
                              if (AuthProvider.of(context).auth.isSignedIn()) {
                                upload();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return NotLoggedInDialogBox(
                                      onLoggedIn: (v) {
                                        upload();
                                      },
                                    );
                                  },
                                );
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          text: "Upload",
        )
      ]),
    );
  }

  bool areWeOkay(dynamic element) {
    return !element.toString().toLowerCase().contains("time") &&
        !element.toString().toLowerCase().contains("#");
  }

  upload() async {
    setState(() {
      processing = true;
    });

    CommunicationServices().showToast(
      "Uploding records. This may take a while",
      Colors.green,
    );

    if (quotationDocuments.isNotEmpty) {
      List pp = [];

      for (var e in quotationDocuments) {
        final csvFile = File(e.path).openRead();
        List df = await csvFile
            .transform(utf8.decoder)
            .transform(
              CsvToListConverter(),
            )
            .toList();

        for (var v in df) {
          bool allGood = true;

          if (!areWeOkay(v.toString())) {
            allGood = false;
          }

          if (allGood) {
            pp.add(v);
          }
        }
      }

      int count = 0;

      for (var element in pp) {
        try {
          dynamic lat = element[1];
          dynamic long = element[2];
          dynamic geovy = element[8];
          dynamic geovx = element[7];
          dynamic geox = element[4];
          dynamic altitude = element[3];
          dynamic geoy = element[5];
          dynamic geoz = element[6];
          dynamic geovz = element[9];
          DateTime dateTime = DateFormat("d/M/y hh:mm").parse(element[0]);

          dynamic electronDensity = getElectronDensity(altitude);

          await FirebaseFirestore.instance.collection(NisnData.DIRECTORY).add({
            NisnData.ADDER: AuthProvider.of(context).auth.getCurrentUID(),
            NisnData.ALTITUDE: altitude,
            NisnData.APPROVED: false,
            NisnData.DATEADDED: DateTime.now().millisecondsSinceEpoch,
            NisnData.TIME: dateTime.millisecondsSinceEpoch,
            NisnData.GEOX: geox,
            NisnData.GEOY: geoy,
            NisnData.GEOZ: geoz,
            NisnData.GEOVX: geovx,
            NisnData.GEOVY: geovy,
            NisnData.LATITUDE: lat,
            NisnData.LONGITUDE: long,
            NisnData.GEOVZ: geovz,
            if (element.length > 10) NisnData.ELECTRONDENSITY: electronDensity,
          }).then((value) async {
            await StorageServices().handleLocationStuffForItems(
              double.parse(lat.toString().trim()),
              double.parse(long.toString().trim()),
              value.id,
              null,
              null,
              null,
              NisnData.DIRECTORY,
            );
          });

          count++;
        } catch (e) {
          setState(() {
            processing = false;
          });

          CommunicationServices().showToast(
            e.toString(),
            Colors.red,
          );
        }
      }

      if (count == pp.length) {
        CommunicationServices().showToast(
          "Successfully uploaded the records.",
          Colors.green,
        );

        NavigationService().pop();
      }
    } else {
      double altitude = double.parse(altitudeController.text.trim());
      dynamic electronDensity = getElectronDensity(altitude);

      FirebaseFirestore.instance.collection(NisnData.DIRECTORY).add({
        NisnData.ADDER: AuthProvider.of(context).auth.getCurrentUID(),
        NisnData.ALTITUDE: double.parse(altitudeController.text.trim()),
        NisnData.APPROVED: false,
        NisnData.DATEADDED: DateTime.now().millisecondsSinceEpoch,
        NisnData.TIME: dateOfRecord.millisecondsSinceEpoch,
        NisnData.GEOX: double.parse(geox.text.trim()),
        NisnData.GEOY: double.parse(geoy.text.trim()),
        NisnData.GEOZ: double.parse(geoz.text.trim()),
        NisnData.LATITUDE: double.parse(latitude.text.trim()),
        NisnData.LONGITUDE: double.parse(longitude.text.trim()),
        NisnData.GEOVX: double.parse(geovx.text.trim()),
        NisnData.GEOVY: double.parse(geovy.text.trim()),
        NisnData.GEOVZ: double.parse(geovz.text.trim()),
        NisnData.ELECTRONDENSITY: electronDensity,
      }).then((value) {
        StorageServices().handleLocationStuffForItems(
          double.parse(latitude.text.trim()),
          double.parse(longitude.text.trim()),
          value.id,
          null,
          null,
          null,
          NisnData.DIRECTORY,
        );

        CommunicationServices().showToast(
          "Successfully added the record",
          Colors.green,
        );

        NavigationService().pop();
      });
    }
  }

  double getElectronDensity(dynamic altitude) {
    dynamic electronDensity = ((9 * 10 ^ 10) / 150) * altitude;

    return electronDensity;
  }
}
