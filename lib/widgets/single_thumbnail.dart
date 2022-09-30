import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/ui.dart';

class SingleThumbnail extends StatelessWidget {
  final dynamic asset;
  final double height;
  final double width;

  final Function onCloseThingiePressed;
  SingleThumbnail({
    Key key,
    @required this.asset,
    @required this.onCloseThingiePressed,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4, top: 4, left: 5),
      decoration: BoxDecoration(
        borderRadius: standardBorderRadius,
      ),
      child: Stack(
        children: <Widget>[
          Container(
            width: width ?? 200,
            height: height ?? 200,
            decoration: BoxDecoration(
              borderRadius: standardBorderRadius,
              image: DecorationImage(
                  image: asset is File
                      ? FileImage(asset)
                      : asset.toString().trim().contains(
                                "assets/images",
                              )
                          ? AssetImage(
                              asset,
                            )
                          : CachedNetworkImageProvider(
                              asset,
                            ),
                  fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  onTap: onCloseThingiePressed,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.close,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
