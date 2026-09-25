import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/models.dart';
import '../theme.dart';

/// Colour + sprite lookup for the three droplet types.
Color dropColorValue(DropColor color) {
  switch (color) {
    case DropColor.cyan:
      return AppColors.primary;
    case DropColor.violet:
      return AppColors.secondary;
    case DropColor.gold:
      return AppColors.gold;
  }
}

String dropAssetFor(DropColor color) {
  switch (color) {
    case DropColor.cyan:
      return AppAssets.dropletCyan;
    case DropColor.violet:
      return AppAssets.dropletViolet;
    case DropColor.gold:
      return AppAssets.dropletGold;
  }
}

/// A single droplet plus its glow halo.
class DropSprite extends StatelessWidget {
  const DropSprite({
    super.key,
    required this.color,
    this.size = 26,
    this.glowOpacity = 0.35,
  });

  final DropColor color;
  final double size;
  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    final Color tint = dropColorValue(color);
    return SizedBox(
      width: size * 1.7,
      height: size * 1.7,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  AppColors.a(tint, glowOpacity),
                  AppColors.a(tint, 0),
                ],
              ),
            ),
            child: SizedBox(width: size * 1.7, height: size * 1.7),
          ),
          Image.asset(
            dropAssetFor(color),
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
