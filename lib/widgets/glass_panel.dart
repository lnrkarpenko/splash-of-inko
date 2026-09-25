import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Frosted surface used for every card, pill and panel in the app.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 20,
    this.blur = 14,
    this.fill = 0.06,
    this.borderOpacity = 0.12,
    this.borderColor,
    this.padding = const EdgeInsets.all(14),
    this.glow,
  });

  final Widget child;
  final double radius;
  final double blur;
  final double fill;
  final double borderOpacity;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final BorderRadius shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: glow == null
            ? null
            : <BoxShadow>[
                BoxShadow(color: glow!, blurRadius: 26, spreadRadius: 1),
              ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.a(AppColors.textPrimary, fill),
              borderRadius: shape,
              border: Border.all(
                color: borderColor ??
                    AppColors.a(AppColors.textPrimary, borderOpacity),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Small capsule label ("LEVEL 3/6", "STARS 7").
class GlassPill extends StatelessWidget {
  const GlassPill({super.key, required this.label, this.icon, this.tint});

  final String label;
  final IconData? icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final Color accent = tint ?? AppColors.textPrimary;
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.a(AppColors.textPrimary, 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.a(AppColors.textPrimary, 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              height: 16 / 11,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular glass icon button (back, settings). 48 dp tap target.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.a(AppColors.textPrimary, 0.08),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 22,
            color: AppColors.a(AppColors.textPrimary, 0.9),
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}
