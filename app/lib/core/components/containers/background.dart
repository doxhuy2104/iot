import 'package:flutter/material.dart';
import 'package:app/core/constants/app_images.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final ImageProvider? bg;

  const BackgroundContainer({super.key, required this.child, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      // To make sure it covers the whole screen
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: bg != null ? bg! : AssetImage(AppImages.imgLogo),
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
        ),
      ),
      child: child,
    );
  }
}
