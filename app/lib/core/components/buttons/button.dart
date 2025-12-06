import 'package:flutter/material.dart';
import 'package:app/core/extensions/widget_extension.dart';

class Button extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPress;
  final BorderRadiusGeometry? borderRadius;
  final bool showEffect;
  const Button({
    super.key,
    required this.child,
    this.onPress,
    this.borderRadius,
    this.showEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias, // for ripple to respect rounded corners
      color: Colors.transparent, // keep image visible
      child: InkWell(
        highlightColor: onPress == null || !showEffect
            ? Colors.transparent
            : null,
        splashColor: onPress == null || !showEffect ? Colors.transparent : null,
        onTap: onPress,
        child: showEffect ? child.inkwell(onPress, force: true) : child,
      ),
    );
  }
}
