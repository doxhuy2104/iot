import 'package:flutter/material.dart';

extension NumExtension on num {
  EdgeInsets paddingAll() => EdgeInsets.all(toDouble());

  /// Padding horizontal
  EdgeInsets paddingHorizontal() =>
      EdgeInsets.symmetric(horizontal: toDouble());

  /// Padding vertical
  EdgeInsets paddingVertical() => EdgeInsets.symmetric(vertical: toDouble());

  /// Padding top
  EdgeInsets paddingTop() => EdgeInsets.only(top: toDouble());

  /// Padding left
  EdgeInsets paddingLeft() => EdgeInsets.only(left: toDouble());

  /// Padding right
  EdgeInsets paddingRight() => EdgeInsets.only(right: toDouble());

  /// Padding bottom
  EdgeInsets paddingBottom() => EdgeInsets.only(bottom: toDouble());
  // ---- end ----

  // Sized box
  /// Creates sized box with width.
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  /// Creates sized box with height.
  SizedBox get verticalSpace => SizedBox(height: toDouble());
}
