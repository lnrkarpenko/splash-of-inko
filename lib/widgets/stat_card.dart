import 'package:flutter/material.dart';

import '../theme.dart';

/// One shared stat card for Menu and GameOver (rule 22): no raster sprites
/// inside, colour carries the meaning, the number is the hero.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    required this.icon,
  });

  final String value;
  final String label;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.a(AppColors.textPrimary, 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.a(valueColor, 0.36), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 20, color: valueColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1.05,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.a(AppColors.textPrimary, 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
