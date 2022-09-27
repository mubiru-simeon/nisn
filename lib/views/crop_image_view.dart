import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import '../constants/constants.dart';
import '../services/communications.dart';

class CropImageView extends StatefulWidget {
  final CropAspectRatio cropAspectRatio;
  final List<File> images;
  final int limit;
  CropImageView({
    Key key,
    @required this.images,
    @required this.limit,
    this.cropAspectRatio,
  }) : super(key: key);

  @override
  State<CropImageView> createState() => _CropImageViewState();
}

class _CropImageViewState extends State<CropImageView> {
  @override
  void initState() {
    super.initState();

    finalList = widget.images;
  }

  List<File> finalList = [];
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return goBackAndReturnTheList();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: finalList.isNotEmpty
                    ? Image(
                        fit: BoxFit.cover,
                        // height: (MediaQuery.of(context).size.height - 110).toInt(),
                        // width: (MediaQuery.of(context).size.width).toInt(),
                        image: FileImage(finalList[count]),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "There are no images selected. Please select some images to continue and tap the icon in the top left corner to edit it",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: CustomScrollView(
                    scrollDirection: Axis.horizontal,
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate([
                          GestureDetector(
                            onTap: () {
                              if (finalList.length >= widget.limit) {
                                CommunicationServices().showSnackBar(
                                  "You are unable to add any more images to this selection",
                                  context,
                                );
                              } else {
                                loadAssets();
                              }
                            },
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.white)),
                              child: Center(
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  count = index;
                                });
                              }
                            },
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: count == index ? 2 : 0,
                                          color: Colors.white)),
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: Image(
                                      image: FileImage(finalList[index]),
                                      height: 60,
                                      width: 60,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(3),
                                      child: InkWell(
                                        onTap: () {
                                          if (mounted) {
                                            setState(() {
                                              if (finalList[index] ==
                                                      finalList.last &&
                                                  finalList.length != 1) {
                                                count = index - 1;
                                              }
                                              finalList.removeAt(index);
                                            });
                                          }
                                        },
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.close,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }, childCount: finalList.length),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    cropThatBissh(count);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 10,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    goBackAndReturnTheList();
                  },
                  label: Text("Done"),
                  icon: Icon(Icons.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  cropThatBissh(int index) async {
    if (finalList.isNotEmpty) {
      CroppedFile croppedFailo = await ImageCropper().cropImage(
        sourcePath: finalList[index].path,
        aspectRatio: widget.cropAspectRatio,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: capitalizedAppName,
              toolbarColor: primaryColor,
              cropGridColor: primaryColor,
              toolbarWidgetColor: primaryColor,
              cropFrameColor: primaryColor,
              activeControlsWidgetColor: primaryColor,
              statusBarColor: primaryColor,
              backgroundColor: primaryColor,
              dimmedLayerColor: primaryColor.withOpacity(0.5))
        ],
      );

      if (croppedFailo != null) {
        File cc = File(croppedFailo.path);

        if (mounted) {
          setState(() {
            finalList.replaceRange(
              index,
              index + 1,
              [
                cc,
              ],
            );
          });
        }
      }
    } else {
      CommunicationServices()
          .showSnackBar("There is no image to edit", context);
    }
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = [];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: widget.limit - finalList.length,
        enableCamera: true,
        //  selectedAssets: finalList,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "ApHO",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
      // ignore: unused_catch_clause, empty_catches
    } on Exception catch (e) {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (resultList.isNotEmpty) {
      final temp = await Directory.systemTemp.createTemp();
      for (int i = 0; i < resultList.length; i++) {
        final data = await resultList[i].getByteData();
        finalList.add(
          await File('${temp.path}/img$i').writeAsBytes(
            data.buffer.asUint8List(
              data.offsetInBytes,
              data.lengthInBytes,
            ),
          ),
        );
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  goBackAndReturnTheList() {
    Navigator.of(context).pop(finalList);
  }
}
