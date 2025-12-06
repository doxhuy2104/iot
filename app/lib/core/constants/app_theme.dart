import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    fontFamily: 'BeVietnamPro',
    brightness: Brightness.light,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      // color: Colors.black,
      // systemOverlayStyle: SystemUiOverlayStyle.light,
      // iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: AppColors.background, // Background color of AppBar
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.light, // Light status bar icons
        statusBarBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      surfaceTintColor: Colors.black,
    ),
    dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary, // Cursor color
      selectionColor: AppColors.primary.withValues(
        alpha: 0.2,
      ), // Background color when text is selected
      selectionHandleColor:
          AppColors.primary, // Handle color (the draggable circles)
    ),
  );
}
