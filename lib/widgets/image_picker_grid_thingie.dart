import 'dart:io';
import 'package:flutter/material.dart';

import '../constants/ui.dart';
import 'dotted_border.dart';
import 'single_thumbnail.dart';

class NewImagePicker extends StatefulWidget {
  final List images;
  final bool imageMode;
  final String text;
  final int crossAxisCount;
  final bool noSliver;
  final Function pickImages;
  NewImagePicker({
    Key key,
    @required this.images,
    this.text,
    @required this.imageMode,
    this.noSliver = false,
    this.crossAxisCount = 3,
    @required this.pickImages,
  }) : super(key: key);

  @override
  State<NewImagePicker> createState() => _NewImagePickerState();
}

class _NewImagePickerState extends State<NewImagePicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: standardBorderRadius,
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      padding: EdgeInsets.all(6),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 4,
              ),
              child: InkWell(
                onTap: () {
                  widget.pickImages();
                },
                child: DottedBorder(
                  strokeWidth: 2,
                  color: Colors.grey,
                  borderType: BorderType.RRect,
                  radius: Radius.circular(borderDouble),
                  dashPattern: [5, 4],
                  padding: EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                          ),
                          Text(
                            widget.text ?? "Add Images",
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.images.isNotEmpty)
            Expanded(
              flex: 2,
              child: widget.images.isEmpty
                  ? Center(
                      child: Text(
                        "No Images Yet",
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: widget.images.map((e) {
                          return SingleThumbnail(
                            asset: e,
                            onCloseThingiePressed: () {
                              if (mounted) {
                                setState(() {
                                  widget.images.remove(e);
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class ImagePickerGridThingie extends StatefulWidget {
  final List images;
  final bool imageMode;
  final String text;
  final int crossAxisCount;
  final bool noSliver;
  final Function pickImages;
  ImagePickerGridThingie({
    Key key,
    @required this.images,
    this.text,
    @required this.imageMode,
    this.noSliver = false,
    this.crossAxisCount = 3,
    @required this.pickImages,
  }) : super(key: key);

  @override
  State<ImagePickerGridThingie> createState() => _ImagePickerGridThingieState();
}

class _ImagePickerGridThingieState extends State<ImagePickerGridThingie> {
  @override
  Widget build(BuildContext context) {
    return !widget.imageMode
        ? widget.noSliver != null && widget.noSliver
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: InkWell(
                  onTap: () {
                    widget.pickImages();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: standardBorderRadius,
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate),
                          Text(widget.text ?? "Add Images")
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      child: InkWell(
                        onTap: () {
                          widget.pickImages();
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: standardBorderRadius,
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate),
                                Text(widget.text ?? "Add Images")
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
        : widget.noSliver != null && widget.noSliver
            ? SizedBox(
                height: 100,
                child: widget.images.isEmpty
                    ? Center(
                        child: Text(
                          "No Images Yet",
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: widget.images.map((e) {
                            return SingleThumbnail(
                              asset: e,
                              onCloseThingiePressed: () {
                                if (mounted) {
                                  setState(() {
                                    widget.images.remove(e);
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
              )
            : SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    File asset = widget.images[index];
                    return SingleThumbnail(
                      asset: asset,
                      onCloseThingiePressed: () {
                        if (mounted) {
                          setState(() {
                            widget.images.remove(widget.images[index]);
                          });
                        }
                      },
                    );
                  },
                  childCount: widget.images.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.crossAxisCount,
                ),
              );
  }

  body() {
    return DottedBorder(
      child: widget.noSliver
          ? GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
              ),
            )
          : SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                File asset = widget.images[index];
                return SingleThumbnail(
                  asset: asset,
                  onCloseThingiePressed: () {
                    if (mounted) {
                      setState(() {
                        widget.images.remove(widget.images[index]);
                      });
                    }
                  },
                );
              }, childCount: widget.images.length),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
              ),
            ),
    );
  }
}
