import 'package:flutter/material.dart';

class CustomSizedBox extends StatelessWidget {
  final SBSize sbSize;
  final bool height;
  final Widget child;
  final double size;

  const CustomSizedBox({
    Key key,
    @required this.sbSize,
    @required this.height,
    this.size = 200,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ? getSize() : null,
      width: !height ? getSize() : null,
      child: child,
    );
  }

  double getSize() {
    return sbSize == SBSize.largest
        ? 60
        : sbSize == SBSize.large
            ? 45
            : sbSize == SBSize.normal
                ? 35
                : sbSize == SBSize.small
                    ? 20
                    : sbSize == SBSize.smallest
                        ? 10
                        : size;
  }
}

enum SBSize {
  largest,
  large,
  normal,
  small,
  smallest,
  custom,
}
