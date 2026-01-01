import 'package:flutter/material.dart';
import 'package:app/core/constants/app_colors.dart';

enum Styles {
  h1(fontSize: 32, height: 1.22),
  h2(fontSize: 28, height: 1.25),
  h3(fontSize: 24, height: 1.29),
  h4(fontSize: 22, height: 1.27),
  h5(fontSize: 18, height: 1.28),
  large(fontSize: 16, height: 1.5),
  xlarge(fontSize: 18, height: 1.5),
  xxlarge(fontSize: 20, height: 1.5),
  medium(fontSize: 14, height: 1.5),
  normal(fontSize: 14, height: 1.5),
  small(fontSize: 12, height: 1.4),
  xsmall(fontSize: 11, height: 1.2),
  sfLarge(fontSize: 16, height: 1.5, fontFamily: 'SF Pro'),
  sfMedium(fontSize: 14, height: 1.5, fontFamily: 'SF Pro'),
  sfNormal(fontSize: 14, height: 1.5, fontFamily: 'SF Pro'),
  sfSmall(fontSize: 12, height: 1.4, fontFamily: 'SF Pro'),
  sfxSmall(fontSize: 11, height: 1.2, fontFamily: 'SF Pro');

  final double fontSize;
  final double height;
  final String? fontFamily;

  const Styles({
    required this.fontSize,
    required this.height,
    this.fontFamily = 'BeVietnamPro',
  });
}

extension
/// `CustomStyleExtension` is an extension on the `Styles` enum in Dart. It adds computed
/// properties to the `Styles` enum values, allowing you to easily access different text
/// styles like bold, semi-bold, medium, and regular based on the specified font size and font
/// weight. This extension simplifies the process of applying different text styles to your UI
/// elements by providing convenient access to predefined text styles.
CustomStyleExtension
    on Styles {
  TextStyle get bold => TextStyle(
    fontSize: fontSize,
    //height: height,
    fontWeight: FontWeight.w900,
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    decoration: TextDecoration.none,
  );

  TextStyle get smb => TextStyle(
    fontSize: fontSize,
    //height: height,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    decoration: TextDecoration.none,
  );

  TextStyle get medium => TextStyle(
    fontSize: fontSize,
    //height: height,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    decoration: TextDecoration.none,
  );

  TextStyle get regular => TextStyle(
    fontSize: fontSize,
    //height: height,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    fontFamily: fontFamily,
    decoration: TextDecoration.none,
  );

  TextStyle get secondary => TextStyle(
    fontSize: fontSize,
    //height: height,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
    decoration: TextDecoration.none,
  );
}
