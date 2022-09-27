import 'package:nisn/services/ui_services.dart';
import 'package:flutter/material.dart';

import '../constants/basic.dart';

class SingleImage extends StatelessWidget {
  final dynamic image;
  final double height;
  final BoxFit fit;
  final Widget placeHolderWidget;
  final String placeholderText;
  final bool darken;
  final double width;
  const SingleImage({
    Key key,
    @required this.image,
    this.height,
    this.placeholderText = capitalizedAppName,
    this.placeHolderWidget,
    this.darken = false,
    this.fit = BoxFit.cover,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return image == null
        ? SizedBox()
        : Image(
            height: height,
            width: width,
            image: UIServices().getImageProvider(image),
            fit: fit,
            colorBlendMode: BlendMode.darken,
            color: Colors.black.withOpacity(
              darken ? 0.6 : 0.0,
            ),
          );
  }
}
