import 'package:flutter/material.dart';

import '../assets.dart';
import '../theme.dart';

/// Gradient call-to-action. Icon is always 24 dp and the label's line height
/// is pinned to 24 so text and icon share one baseline (rule 21).
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.height = 60,
    this.fontSize = 17,
    this.radius = 18,
    this.enabled = true,
    this.glow,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final double height;
  final double fontSize;
  final double radius;
  final bool enabled;
  final Color? glow;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  void _setDown(bool value) {
    if (_down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final Color glowColor = widget.glow ?? AppColors.a(AppColors.primary, 0.42);
    final BorderRadius shape = BorderRadius.circular(widget.radius);

    return Opacity(
      opacity: widget.enabled ? 1 : 0.45,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: GestureDetector(
          onTapDown: widget.enabled ? (_) => _setDown(true) : null,
          onTapUp: widget.enabled ? (_) => _setDown(false) : null,
          onTapCancel: widget.enabled ? () => _setDown(false) : null,
          onTap: widget.enabled ? widget.onTap : null,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.ctaGradient,
              borderRadius: shape,
              image: DecorationImage(
                image: const AssetImage(AppAssets.buttonCta),
                fit: BoxFit.cover,
                opacity: 0.55,
                colorFilter: ColorFilter.mode(
                  AppColors.a(AppColors.primary, 0.22),
                  BlendMode.overlay,
                ),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: glowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (widget.icon != null) ...<Widget>[
                  Icon(widget.icon, size: 24, color: AppColors.textPrimary),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                    height: 24 / widget.fontSize,
                    color: AppColors.textPrimary,
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

/// Flat glass button used for the secondary row.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.tint,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final Color accent = tint ?? AppColors.a(AppColors.textPrimary, 0.88);
    return Material(
      color: AppColors.a(AppColors.textPrimary, 0.07),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.a(AppColors.textPrimary, 0.14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 24, color: accent),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  height: 24 / 13,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
