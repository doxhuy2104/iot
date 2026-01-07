import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:app/core/constants/app_keys.dart';
import 'package:app/core/helpers/general_helper.dart';

class AppDimensions {
  AppDimensions._();

  static double get fullscreenHeight =>
      MediaQuery.of(AppKeys.navigatorKey.currentContext!).size.height;
  static double get fullscreenWidth =>
      MediaQuery.of(AppKeys.navigatorKey.currentContext!).size.width;
  static double insetBottom(BuildContext? context) => max(
    GeneralHelper.osInfo == 'android' ? 12 : -1,
    (MediaQuery.of(
      context ?? AppKeys.navigatorKey.currentContext!,
    ).padding.bottom),
  );
  static double insetTop(BuildContext? context) => MediaQuery.of(
    context ?? AppKeys.navigatorKey.currentContext!,
  ).padding.top;
  static double get paddingNavBar => 82;
  static double get paddingNavBarAdd => 32;
  static double paddingStatusBar(BuildContext? context) =>
      (GeneralHelper.osInfo == 'android' ? 20 : 8);
  static double keyboardHeight(BuildContext? context) => MediaQuery.of(
    context ?? AppKeys.navigatorKey.currentContext!,
  ).viewInsets.bottom;
  static double get headerHeight => 32;
  static double get mainPageHeight => 52;
  static double get mainPadding => 16;
}
