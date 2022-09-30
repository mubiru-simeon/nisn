import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/constants.dart';
import '../views/crop_image_view.dart';
import '../widgets/top_back_bar.dart';
import 'communications.dart';
import 'navigation.dart';
import 'ui_services.dart';

class ImageServices {
  Future<List<String>> uploadFiles({
    @required String path,
    @required Function onError,
    @required List<PlatformFile> files,
    Uint8List bytes,
    String extension,
  }) async {
    List<String> imgUrls = [];

    if ((files == null || files.isEmpty) && (bytes == null || bytes.isEmpty)) {
      return imgUrls;
    } else {
      try {
        if (files != null && files.isNotEmpty) {
          for (var element in files) {
            if (element is String) {
              imgUrls.add(element.toString());
            } else {
              List<int> imageData = element.bytes;
              Reference ref = FirebaseStorage.instance
                  .ref()
                  .child(
                    path ?? "files",
                  )
                  .child(
                    element.name,
                  );
              UploadTask uploadTask = ref.putData(imageData);
              String url = await (await uploadTask).ref.getDownloadURL();
              imgUrls.add(url);
            }
          }
        } else {
          String tyme = DateTime.now().toString();
          Reference ref = FirebaseStorage.instance
              .ref()
              .child(
                path ?? "files",
              )
              .child(
                "$tyme.$extension",
              );
          UploadTask uploadTask = ref.putData(bytes);
          String url = await (await uploadTask).ref.getDownloadURL();
          imgUrls.add(url);
        }

        return imgUrls;
        // ignore: unused_catch_clause
      } on Exception catch (e) {
        onError();
        return [];
      }
    }
  }

  String _convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if (!url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    for (var exp in [
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(
          r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  String getThumb(String link) {
    String thumbNail;

    if (link.contains("youtu")) {
      String videoID = _convertUrlToId(link);
      thumbNail = _getThumbnail(videoId: videoID ?? "");
    } else {
      thumbNail = link;
    }

    return thumbNail;
  }

  String _getThumbnail({
    @required String videoId,
    String quality = "hqdefault",
    bool webp = true,
  }) {
    return webp
        ? 'https://i3.ytimg.com/vi_webp/$videoId/$quality.webp'
        : 'https://i3.ytimg.com/vi/$videoId/$quality.jpg';
  }

  Future<List<File>> pickImages(BuildContext context, {int limit = 10}) async {
    List<File> returnThis = [];

    await UIServices().showDatSheet(
      ImageOptionsBottomSheet(
        onCameraTap: () async {
          returnThis = await goToCamera(context, limit);

          NavigationService().pop();
        },
        onGalleryTap: () async {
          returnThis = await goToMultiPicker(context, limit);

          NavigationService().pop();
        },
      ),
      false,
      context,
      height: MediaQuery.of(context).size.height * 0.4,
    );

    return returnThis;
  }

  Future<List<File>> goToMultiPicker(
    BuildContext context,
    int limit,
  ) async {
    NavigationService().push(
      ImageWorks(),
    );

    List<File> images = [];
    List<Asset> resultList = [];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: limit,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: capitalizedAppName,
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      CommunicationServices().showToast(e.toString(), primaryColor);
    }

    if (resultList.isNotEmpty) {
      images.clear();

      List<File> tempFileList = [];
      final temp = await Directory.systemTemp.createTemp();
      for (int i = 0; i < resultList.length; i++) {
        final data = await resultList[i].getByteData();
        tempFileList.add(
          await File('${temp.path}/img$i').writeAsBytes(
            data.buffer.asUint8List(
              data.offsetInBytes,
              data.lengthInBytes,
            ),
          ),
        );
      }

      images = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropImageView(
            limit: limit,
            images: tempFileList,
          ),
        ),
      );

      Navigator.of(context).pop();

      return images;
    } else {
      images.clear();
      Navigator.of(context).pop();
      return images;
    }
  }

  Future<List<File>> goToCamera(
    BuildContext context,
    int limit,
  ) async {
    return [];
  }

  Future<List<String>> uploadImages({
    @required String path,
    @required Function onError,
    @required List images,
    Uint8List bytes,
  }) async {
    List<String> imgUrls = [];

    if ((images == null || images.isEmpty || images[0] == null) &&
        (bytes == null || bytes.isEmpty)) {
      return imgUrls;
    } else {
      try {
        if (images != null && images.isNotEmpty) {
          for (var element in images) {
            if (element is File) {
              List<int> imageData = await element.readAsBytes();
              String tyme = DateTime.now().toString();
              Reference ref = FirebaseStorage.instance
                  .ref()
                  .child(
                    path ?? "images",
                  )
                  .child(
                    "$tyme.jpg",
                  );
              UploadTask uploadTask = ref.putData(imageData);
              String url = await (await uploadTask).ref.getDownloadURL();
              imgUrls.add(url);
            } else {
              if (element.toString().trim().contains(
                    "assets/images",
                  )) {
              } else {
                if (element is String) {
                  imgUrls.add(element.toString());
                }
              }
            }
          }
        } else {
          String tyme = DateTime.now().toString();
          Reference ref = FirebaseStorage.instance
              .ref()
              .child(
                path ?? "images",
              )
              .child(
                "$tyme.jpg",
              );
          UploadTask uploadTask = ref.putData(bytes);
          String url = await (await uploadTask).ref.getDownloadURL();
          imgUrls.add(url);
        }

        return imgUrls;
        // ignore: unused_catch_clause
      } on Exception catch (e) {
        onError();
        return [];
      }
    }
  }

  Future<bool> downloadFile(
    String link,
    Function onError,
  ) async {
    Directory dd = await getApplicationDocumentsDirectory();
    var ref = FirebaseStorage.instance.refFromURL(link);

    File download = File(
      "${dd.path}/${ref.name}",
    );

    try {
      return await FirebaseStorage.instance
          .ref(ref.fullPath)
          .writeToFile(download)
          .then((p0) {
        return true;
      });
    } catch (e) {
      onError();

      return false;
    }
  }
}

class ImageWorks extends StatelessWidget {
  const ImageWorks({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
    );
  }
}

class ImageOptionsBottomSheet extends StatelessWidget {
  final Function onCameraTap;
  final Function onGalleryTap;
  const ImageOptionsBottomSheet({
    Key key,
    @required this.onCameraTap,
    @required this.onGalleryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Select An Option",
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      onCameraTap();
                    },
                    icon: Icon(
                      Icons.camera,
                    ),
                  ),
                  Text(
                    "Camera",
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  IconButton(
                    onPressed: () {
                      onGalleryTap();
                    },
                    icon: Icon(
                      Icons.add_photo_alternate,
                    ),
                  ),
                  Text(
                    "Gallery",
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
