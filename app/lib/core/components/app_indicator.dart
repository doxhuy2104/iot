import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_keys.dart';
import 'package:flutter/material.dart';

class AppIndicator {
  static bool _isShowing = false;
  static OverlayEntry? _overlayEntry;

  /// Show loading indicator with dimmed background
  static void show({bool dissmissible = false}) {
    if (_isShowing) return; // Prevent multiple indicators

    final context = AppKeys.navigatorKey.currentContext;
    if (context == null) return;

    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.5), // Dimmed background
        child: Center(
          child: GestureDetector(
            onTap: dissmissible ? hide : null,
            behavior: HitTestBehavior.opaque,
            child: GestureDetector(
              onTap: () {}, // Prevent tap through to background
              child: const _LoadingIndicatorWidget(),
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = AppKeys.navigatorKey.currentState?.overlay;
      if (overlay != null) {
        overlay.insert(_overlayEntry!);
      } else {
        _isShowing = false;
      }
    });
  }

  /// Hide loading indicator specifically
  static void hide() {
    if (!_isShowing || _overlayEntry == null) return;

    _isShowing = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Check if indicator is currently showing
  static bool get isShowing => _isShowing;
}

class _LoadingIndicatorWidget extends StatelessWidget {
  const _LoadingIndicatorWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary color circular progress indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
