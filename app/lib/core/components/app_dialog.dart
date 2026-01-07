import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/components/buttons/secondary_button.dart';
import 'package:app/core/components/buttons/primary_button.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_icons.dart';
import 'package:app/core/constants/app_keys.dart';
import 'package:app/core/constants/app_styles.dart';
import 'package:app/core/extensions/localized_extension.dart';
import 'package:app/core/extensions/num_extension.dart';

enum AppDialogType { success, failed }

class AppDialog {
  static bool isShowing = false;
  static void show({
    required String title,
    String? message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool dismissible = true,
    AppDialogType? type,
    String? dialogIcon,
    Color? confirmColor,
  }) {
    if (isShowing) {
      return;
    }
    isShowing = true;
    // hide();
    showGeneralDialog(
      barrierDismissible: false,
      barrierLabel: '',
      context: AppKeys.navigatorKey.currentContext!,
      barrierColor: Colors.black.withValues(alpha: 0.7),

      /// The commented out `transitionBuilder` section in the `showGeneralDialog` method is used to
      /// define the transition animation that occurs when the dialog is displayed on the screen. In this
      /// case, it is creating a transition effect that combines scaling and fading of the dialog.
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuad,
            ),
            child: child,
          ),
        );
      },

      pageBuilder: (context, animation, secondaryAnimation) {
        return PopScope(
          canPop: dismissible,
          child: Container(
            // canPop: dismissible,
            alignment: Alignment.center,
            child: _AppDialogWidget(
              title: title,
              message: message,
              confirmText: confirmText,
              cancelText: cancelText,
              onConfirm: onConfirm,
              onCancel: onCancel,
              type: type,
              dissmissible: dismissible,
              dialogIcon: dialogIcon,
              confirmColor: confirmColor,
            ),
          ),
        );
      },
    ).then((_) {
      isShowing = false;
    });
  }

  static hide() {
    if (!isShowing) return;
    isShowing = false;
    Navigator.of(AppKeys.navigatorKey.currentContext!).pop();
  }
}

class _AppDialogWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final AppDialogType? type;
  final bool dissmissible;
  final String? dialogIcon;
  final Color? confirmColor;

  const _AppDialogWidget({
    this.title,
    this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.type,
    this.dissmissible = true,
    this.dialogIcon,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = type == AppDialogType.success
        ? AppColors.success
        : AppColors.fail;

    void onClose() {
      AppDialog.hide();
    }

    return Dialog(
      insetPadding: EdgeInsets.all(20),
      backgroundColor: Colors.black.withValues(alpha: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(24),
        child: Container(
          // filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          decoration: BoxDecoration(color: Colors.white),
          child: Container(
            padding: const EdgeInsets.all(32),
            // color: Colors.transparent,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  blurStyle: BlurStyle.outer,
                  color: AppColors.primary,
                  blurRadius: 1,
                  offset: Offset(0, 3),
                  spreadRadius: 2,
                ),
                // BoxShadow(
                //   blurStyle: BlurStyle.inner,
                //   color: AppColors.primaryHighlight,
                //   blurRadius: 1000000,
                //   offset: Offset(0, 0),
                //   spreadRadius: 0
                // ),
              ],
              // color: Colors.black.withValues(alpha: 0.6),
            ),
            child: Stack(
              children: [
                // Close button at top right
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    8.verticalSpace,

                    // show mascot icon if type!=null here
                    if (type != null && dialogIcon == null) ...[
                      SvgPicture.asset(
                        type == AppDialogType.success
                            ? AppIcons.icSuccessLogo
                            : AppIcons.icFailLogo,
                        width: 240,
                        height: 240,
                        fit: BoxFit.contain,
                      ),
                      8.verticalSpace,
                    ],
                    if (dialogIcon != null &&
                        !dialogIcon!.endsWith('.svg')) ...[
                      Image.asset(
                        dialogIcon!,
                        width: 240,
                        height: 240,
                        fit: BoxFit.contain,
                      ),
                      8.verticalSpace,
                    ],
                    if (dialogIcon != null && dialogIcon!.endsWith('.svg')) ...[
                      SvgPicture.asset(
                        dialogIcon!,
                        width: 240,
                        height: 240,
                        fit: BoxFit.contain,
                      ),
                      8.verticalSpace,
                    ],
                    // Title
                    Text(
                      title!,
                      style: Styles.large.smb.copyWith(
                        color: type != null ? typeColor : Colors.black,
                        // fontSize: 26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Message
                    if (message != null) ...[
                      8.verticalSpace,

                      Text(
                        message!,
                        style: Styles.medium.regular,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    24.verticalSpace,

                    // Buttons
                    PrimaryButton(
                      text: confirmText ?? context.localization.close,
                      onPress: () {
                        onClose();
                        onConfirm?.call();
                      },
                    ),
                    if (cancelText != null) ...[
                      12.verticalSpace,
                      SecondaryButton(text: cancelText!, onPress: onClose),
                    ],
                  ],
                ),
                if (dissmissible)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onClose,
                      child: Container(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          AppIcons.icClose,
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
