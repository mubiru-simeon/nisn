import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nisn/constants/ui.dart';

import 'package:nisn/services/communications.dart';

import 'custom_sized_box.dart';

class ProceedButton extends StatefulWidget {
  final String text;
  final String processingText;
  final BorderRadius borderRadius;
  final Function onTap;
  final bool outlined;
  final Color color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool enablable;
  final bool enabled;
  final Widget child;
  final bool processable;
  final bool processing;
  final double textSize;

  ProceedButton({
    Key key,
    @required this.onTap,
    this.text,
    this.outlined = false,
    this.enablable = false,
    this.processable = false,
    this.color,
    this.enabled,
    this.processingText,
    this.padding = const EdgeInsets.all(10),
    this.margin = const EdgeInsets.only(
      left: 5,
      right: 5,
      bottom: 5,
      top: 5,
    ),
    this.borderRadius,
    this.child,
    this.processing,
    this.textSize,
  }) : super(key: key);

  @override
  State<ProceedButton> createState() => _ProceedButtonState();
}

class _ProceedButtonState extends State<ProceedButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: InkWell(
              onTap: widget.processable != null && widget.processable
                  ? widget.processing
                      ? () {
                          CommunicationServices().showToast(
                            "Processing. Please wait..",
                            primaryColor,
                          );
                        }
                      : widget.enablable != null && widget.enablable
                          ? widget.enabled
                              ? widget.onTap
                              : null
                          : widget.onTap
                  : widget.enablable != null && widget.enablable
                      ? widget.enabled
                          ? widget.onTap
                          : null
                      : widget.onTap,
              child: Container(
                  width: double.infinity,
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    border: widget.outlined != null && widget.outlined
                        ? Border.all(
                            width: 1,
                          )
                        : null,
                    color: widget.outlined != null && widget.outlined
                        ? null
                        : widget.enablable != null && widget.enablable
                            ? widget.enabled
                                ? widget.color ?? primaryColor
                                : Colors.grey
                            : widget.color ?? primaryColor,
                    borderRadius: widget.borderRadius ?? standardBorderRadius,
                  ),
                  child: Center(
                    child: widget.processable != null && widget.processable
                        ? widget.processing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SpinKitWave(
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  CustomSizedBox(
                                    sbSize: SBSize.small,
                                    height: false,
                                  ),
                                  if (widget.processingText != null)
                                    Text(
                                      widget.processingText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                ],
                              )
                            : widget.text == null
                                ? widget.child
                                : Text(
                                    widget.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                        : widget.text == null
                            ? widget.child
                            : Text(
                                widget.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: widget.textSize ?? 16,
                                  color:
                                      widget.outlined != null && widget.outlined
                                          ? null
                                          : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
