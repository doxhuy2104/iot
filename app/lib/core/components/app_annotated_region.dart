import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppAnnotatedRegion extends StatelessWidget {
  const AppAnnotatedRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Transparent status bar
        statusBarIconBrightness: Brightness.light, // Light status bar icons
        statusBarBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: child,
    );
  }
}
