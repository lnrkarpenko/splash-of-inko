import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/models.dart';
import '../theme.dart';
import 'drop_sprite.dart';

/// Glass reservoir under the board. Same widget on the board and on the
/// result screen (read-only there), so the two screens stay consistent.
class TankGauge extends StatelessWidget {
  const TankGauge({
    super.key,
    required this.spec,
    required this.fill,
    required this.tainted,
    this.height = 68,
  });

  final TankSpec spec;

  /// Continuous fill in drops (fractional while a droplet is settling).
  final double fill;
  final bool tainted;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Color tint = dropColorValue(spec.target);
    final Color border = tainted ? AppColors.danger : tint;
    final double ratio =
        spec.capacity == 0 ? 0 : (fill / spec.capacity).clamp(0.0, 1.0);
    final int shown = fill.floor().clamp(0, spec.capacity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.a(AppColors.textPrimary, 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.a(border, 0.75), width: 1.5),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                  opacity: 0.30,
                  child: Image.asset(
                    AppAssets.tank,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: (height - 6) * ratio,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            AppColors.a(tint, 0.95),
                            AppColors.a(tint, 0.55),
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.a(AppColors.textPrimary, 0.7),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (tainted)
                  ColoredBox(color: AppColors.a(AppColors.danger, 0.30)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$shown/${spec.capacity}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: tainted ? AppColors.danger : tint,
          ),
        ),
      ],
    );
  }
}
