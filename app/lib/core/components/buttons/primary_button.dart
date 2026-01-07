import 'package:flutter/material.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_styles.dart';

class PrimaryButton extends StatelessWidget {
  final double? height;
  final String? text;
  final void Function() onPress;
  final bool disabled;
  const PrimaryButton({
    super.key,
    this.height,
    this.text,
    required this.onPress,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: height ?? 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(44)),
            color: AppColors.primary,
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            ),
            onPressed: disabled ? null : onPress,
            child: Text(
              text!,
              style: Styles.large.regular.copyWith(
                color: disabled
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.white,
              ),
            ),
          ),
        ),
        if (disabled) ...[
          Container(
            width: double.infinity,
            height: height ?? 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(44)),
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      ],
    );
  }
}
