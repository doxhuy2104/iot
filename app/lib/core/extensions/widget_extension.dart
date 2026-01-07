import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  Padding paddingAll(double value, {Key? key}) {
    return Padding(key: key, padding: EdgeInsets.all(value), child: this);
  }

  Padding paddingLTRB(
    double left,
    double top,
    double right,
    double bottom, {
    Key? key,
  }) => Padding(
    key: key,
    padding: EdgeInsets.fromLTRB(left, top, right, bottom),
    child: this,
  );

  Padding paddingSymmetric({Key? key, double v = 0.0, double h = 0.0}) =>
      Padding(
        key: key,
        padding: EdgeInsets.symmetric(vertical: v, horizontal: h),
        child: this,
      );

  Padding paddingOnly({
    Key? key,
    double left = 0.0,
    double right = 0.0,
    double top = 0.0,
    double bottom = 0.0,
  }) => Padding(
    key: key,
    padding: EdgeInsets.only(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
    ),
    child: this,
  );

  Widget inkwell(
    Function()? function, {
    double borderRadius = 0,
    bool force = false,
  }) => function == null
      ? this
      : !force
      ? InkWell(
          onTap: function,
          borderRadius: BorderRadius.circular(borderRadius),
          child: this,
        )
      : Stack(
          fit: StackFit.passthrough,
          children: [
            this,
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: function,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
          ],
        );
  Container withRoundCorners({
    required Color backgroundColor,
    double? radius,
    double borderWidth = 0,
    Color borderColor = Colors.transparent,
  }) => Container(
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: backgroundColor,
      border: Border.all(
        width: borderWidth,
        color: borderColor,
        style: borderWidth > 0 ? BorderStyle.solid : BorderStyle.none,
      ),
      borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
    ),
    child: this,
  );

  Container withShadow({
    Color shadowColor = Colors.grey,
    double blurRadius = 20.0,
    double spreadRadius = 1.0,
    Offset offset = const Offset(10.0, 10.0),
  }) => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          offset: offset,
        ),
      ],
    ),
    child: this,
  );

  Positioned positioned({
    double? top,
    double? bottom,
    double? left,
    double? right,
    double? height,
    double? width,
  }) => Positioned(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    height: height,
    width: width,
    child: this,
  );
}
