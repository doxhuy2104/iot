// ignore_for_file: constant_identifier_names

import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_dimensions.dart';
import 'package:app/core/constants/app_styles.dart';
import 'package:app/core/helpers/general_helper.dart';

import 'navigation_bar_item.dart';

const double DEFAULT_BAR_HEIGHT = 82;

const double DEFAULT_CENTER_BTN_HEIGHT = 99;

const double DEFAULT_INDICATOR_HEIGHT = 2;

// ignore: must_be_immutable
class TitledBottomNavigationBar extends StatefulWidget {
  final bool reverse;
  final Curve curve;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? inactiveStripColor;
  final Color? indicatorColor;
  final bool enableShadow;
  int currentIndex;

  /// Called when a item is tapped.
  ///
  /// This provide the selected item's index.
  final ValueChanged<int> onTap;

  /// The items of this navigation bar.
  ///
  /// This should contain at least two items and five at most.
  final List<TitledNavigationBarItem> items;

  /// Change the navigation bar's size.
  ///
  /// Defaults to [DEFAULT_BAR_HEIGHT].
  final double height;

  TitledBottomNavigationBar({
    super.key,
    this.reverse = false,
    this.curve = Curves.linear,
    required this.onTap,
    required this.items,
    this.activeColor,
    this.inactiveColor,
    this.inactiveStripColor,
    this.indicatorColor,
    this.enableShadow = true,
    this.currentIndex = 0,
    this.height = DEFAULT_BAR_HEIGHT,
  }) : assert(items.length >= 2 && items.length <= 5);

  @override
  State createState() => _TitledBottomNavigationBarState();
}

class _TitledBottomNavigationBarState extends State<TitledBottomNavigationBar> {
  bool get reverse => widget.reverse;

  Curve get curve => widget.curve;

  List<TitledNavigationBarItem> get items => widget.items;

  double width = AppDimensions.fullscreenWidth - 12 * 2;
  Color? activeColor;
  Duration duration = const Duration(milliseconds: 270);

  @override
  Widget build(BuildContext context) {
    // int middleIndex = (items.length / 2).floor();

    final double height =
        widget.height +
        (GeneralHelper.osInfo == 'iOS'
            ? 0
            : (AppDimensions.insetBottom(context) > 16
                  ? AppDimensions.insetBottom(context) - 12
                  : 0));
    return Container(
      height: height,
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      margin: EdgeInsets.only(bottom: 0, right: 0, left: 0),
      color: Colors.white,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  height: height,
                  clipBehavior: Clip.none,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 60,
                        spreadRadius: 60,
                        offset: Offset(0, 0),
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(0),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(right: 6, left: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    // fit: StackFit.expand,
                    // alignment: Alignment.center,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        if (true) ...[
                          Expanded(
                            child: InkWell(
                              onTap: () => _select(i),
                              child: Container(
                                padding: EdgeInsets.only(top: 12),
                                child: _buildItemWidget(
                                  items[i],
                                  i == widget.currentIndex,
                                  showText: true,
                                  iconSize: null,
                                ),
                              ),
                            ),
                          ),
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          // if (items.length % 2 == 1) ...[
          //   Positioned(
          //     bottom: 14,
          //     child: InkWell(
          //       onTap: () => _select(middleIndex),
          //       child: Container(
          //         color: Colors.transparent,
          //         height: DEFAULT_CENTER_BTN_HEIGHT,
          //         width: width / items.length,
          //         child: _buildItemWidget(
          //           items[middleIndex],
          //           middleIndex == widget.currentIndex,
          //           spacing: 0,
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  void _select(int index) {
    widget.currentIndex = index;
    widget.onTap(widget.currentIndex);

    setState(() {});
  }

  Widget _buildIcon(
    TitledNavigationBarItem item,
    bool isSelected, {
    double? width,
  }) {
    if (item.icon != null) {
      return Icon(
        isSelected ? item.activeIcon! : item.icon!,
        color: isSelected ? AppColors.primary : AppColors.secondaryText,
      );
    } else {
      // check if png
      if (item.iconPath!.endsWith('.png')) {
        return Image.asset(
          isSelected ? item.activeIconPath! : item.iconPath!,
          fit: BoxFit.contain,
          width: width,
          height: width,
        );
      }
      return SvgPicture.asset(
        colorFilter: ColorFilter.mode(
          isSelected ? AppColors.primary : AppColors.secondaryText,
          BlendMode.srcIn,
        ),
        isSelected ? item.activeIconPath! : item.iconPath!,
        fit: BoxFit.contain,
        width: width,
        height: width,
      );
    }
    return Container();
  }

  Widget _buildText(TitledNavigationBarItem item, bool isSelected) {
    return Text(
      item.title,
      style: Styles.small.smb.copyWith(
        color: isSelected ? AppColors.primary : AppColors.secondaryText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildItemWidget(
    TitledNavigationBarItem item,
    bool isSelected, {
    double? spacing,
    bool? showText = true,
    double? iconSize,
  }) {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: spacing ?? 4,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildIcon(item, isSelected, width: iconSize),
          if (showText == true) _buildText(item, isSelected),
        ],
      ),
    );
  }
}
