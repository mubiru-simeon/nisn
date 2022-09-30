import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nisn/models/nisnInfo.dart';
import 'package:nisn/services/auth_provider_widget.dart';
import 'package:nisn/services/communications.dart';
import 'package:nisn/services/date_service.dart';
import 'package:nisn/services/image_services.dart';
import 'package:nisn/services/navigation.dart';
import 'package:nisn/services/ui_services.dart';
import 'package:nisn/widgets/image_picker_grid_thingie.dart';
import 'package:nisn/widgets/not_logged_in_dialog_box.dart';
import 'package:nisn/widgets/pictures_grid.dart';
import 'package:nisn/widgets/proceed_button.dart';
import 'package:nisn/widgets/top_back_bar.dart';

import '../constants/ui.dart';
import '../widgets/custom_sliver_app_bar.dart';
import '../widgets/paginate_firestore/paginate_firestore.dart';
import 'no_data_found_view.dart';

class InfoView extends StatefulWidget {
  InfoView({
    Key key,
  }) : super(key: key);

  @override
  State<InfoView> createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Stack(
      children: [
        PaginateFirestore(
          isLive: true,
          header: CustomSliverAppBar(
            title: "Useful Data",
            pushed: false,
          ),
          onEmpty: NoDataFound(
            text: "No Info Yet",
            doSthText: "Tap here and be the first to submit data",
          ),
          itemBuilderType: PaginateBuilderType.listView,
          itemsPerPage: 5,
          itemBuilder: (context, snapshot, index) {
            NisnInfo nisnData = NisnInfo.fromSnapshot(snapshot[index]);

            return GestureDetector(
              onTap: () {
                UIServices().showDatSheet(
                  InfoDetailsBottomSheet(
                    nisnData: nisnData,
                  ),
                  true,
                  context,
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 5,
                ),
                child: Material(
                  borderRadius: standardBorderRadius,
                  elevation: standardElevation,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (nisnData.images.isNotEmpty)
                          PicturesGrid(
                            images: nisnData.images,
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          nisnData.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          nisnData.desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          query: FirebaseFirestore.instance
              .collection(NisnInfo.DIRECTORY)
              .orderBy(NisnInfo.TIME, descending: true),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: FloatingActionButton(
              child: Icon(
                Icons.add,
              ),
              onPressed: () {
                UIServices().showDatSheet(
                  AddNisnInfoBottomSheet(),
                  true,
                  context,
                );
              }),
        )
      ],
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}

class AddNisnInfoBottomSheet extends StatefulWidget {
  AddNisnInfoBottomSheet({
    Key key,
  }) : super(key: key);

  @override
  State<AddNisnInfoBottomSheet> createState() => _AddNisnInfoBottomSheetState();
}

class _AddNisnInfoBottomSheetState extends State<AddNisnInfoBottomSheet> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  List images = [];
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Add some Nisn Info",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Title",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: descController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Description",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ImagePickerGridThingie(
                        images: images,
                        imageMode: false,
                        noSliver: true,
                        pickImages: () async {
                          List pp = await ImageServices().pickImages(context);

                          if (pp.isNotEmpty) {
                            setState(() {
                              for (var element in pp) {
                                images.add(element);
                              }
                            });
                          }
                        }),
                    ImagePickerGridThingie(
                      images: images,
                      imageMode: true,
                      noSliver: true,
                      pickImages: () async {
                        List pp = await ImageServices().pickImages(context);

                        if (pp.isNotEmpty) {
                          setState(() {
                            for (var element in pp) {
                              images.add(element);
                            }
                          });
                        }
                      },
                    )
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
          text: "Proceed",
          onTap: () async {
            if (titleController.text.trim().isEmpty) {
              CommunicationServices().showToast(
                "Please provide a title",
                Colors.red,
              );
            } else {
              if (descController.text.trim().isEmpty) {
                CommunicationServices().showToast(
                  "Please provide a description",
                  Colors.red,
                );
              } else {
                if (AuthProvider.of(context).auth.isSignedIn()) {
                  upload();
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return NotLoggedInDialogBox(onLoggedIn: (v) {
                          upload();
                        });
                      });
                }
              }
            }
          },
        )
      ]),
    );
  }

  upload() async {
    setState(() {
      processing = true;
    });

    List pp = await ImageServices().uploadImages(
      path: "info_images",
      onError: () {
        setState(() {
          processing = false;
        });

        CommunicationServices().showToast(
          "Error uploading images. Check your internet connection and try again.",
          Colors.red,
        );
      },
      images: images,
    );

    FirebaseFirestore.instance.collection(NisnInfo.DIRECTORY).add({
      NisnInfo.TITLE: titleController.text.trim(),
      NisnInfo.DESC: descController.text.trim(),
      NisnInfo.IMAGES: pp,
      NisnInfo.TIME: DateTime.now().millisecondsSinceEpoch,
      NisnInfo.ADDER: AuthProvider.of(context).auth.getCurrentUID(),
    }).then((value) {
      NavigationService().pop();

      CommunicationServices().showToast(
        "Successfully added the info",
        Colors.green,
      );
    });
  }
}

class InfoDetailsBottomSheet extends StatefulWidget {
  final NisnInfo nisnData;
  InfoDetailsBottomSheet({
    Key key,
    @required this.nisnData,
  }) : super(key: key);

  @override
  State<InfoDetailsBottomSheet> createState() => _InfoDetailsBottomSheetState();
}

class _InfoDetailsBottomSheetState extends State<InfoDetailsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Info Details",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.nisnData.images.isNotEmpty)
                    PicturesGrid(
                      images: widget.nisnData.images,
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.nisnData.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.nisnData.desc,
                  ),
                ],
              ),
            ),
          ),
        ),
        Text(
          DateService().dateFromMilliseconds(
            widget.nisnData.date,
          ),
        ),
      ],
    );
  }
}
