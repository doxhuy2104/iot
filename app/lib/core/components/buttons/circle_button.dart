import 'package:flutter/material.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_styles.dart';

class CircleButton extends StatelessWidget {
  final void Function() onPress;
  final bool disabled;
  final Widget? icon;
  final double? size;

  const CircleButton({
    super.key,
    this.size,
    required this.onPress,
    this.disabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size ?? 44,
          height: size ?? 44,

          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            // border: BoxBorder.all(color: AppColors.primary, width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(44),

            onTap: disabled ? null : onPress,
            child: icon,
          ),
        ),
      ],
    );
  }
}
