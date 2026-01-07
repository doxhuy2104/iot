import 'package:flutter/material.dart';

class TitledNavigationBarItem {
  /// The title of this item.
  final String title;

  /// The icon of this item.
  ///
  /// If this is not a [Icon] widget, you must handle the color manually.
  final String? iconPath;
  final String? activeIconPath;
  final IconData? icon;
  final IconData? activeIcon;

  /// The background color of this item.
  ///
  /// Defaults to [Colors.white].
  final Color backgroundColor;

  TitledNavigationBarItem({
    this.iconPath,
    this.activeIconPath,
    required this.title,
    this.icon,
    this.activeIcon,
    this.backgroundColor = Colors.white,
  });
}
