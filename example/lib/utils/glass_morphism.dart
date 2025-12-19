import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:morpheus_launcher_gui/globals.dart';

class GlassMorphism extends StatelessWidget {
  final double blur;
  final double opacity;
  final double radius;
  final Widget child;

  const GlassMorphism({
    Key? key,
    required this.blur,
    required this.opacity,
    required this.radius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: ColorUtils.dynamicBackgroundColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              width: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
