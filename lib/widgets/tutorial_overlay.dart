import 'package:flutter/material.dart';

import '../assets.dart';
import '../theme.dart';
import 'glass_panel.dart';
import 'primary_button.dart';

/// How-to card shown on top of the board. It is an overlay, never a route:
/// a mandatory screen between the menu and the board traps the capture agent.
class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _demo;

  @override
  void initState() {
    super.initState();
    _demo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _demo.dispose();
    super.dispose();
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 22 / 13,
                color: AppColors.a(AppColors.textPrimary, 0.88),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.a(AppColors.bgDarkest, 0.78),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: GlassPanel(
              radius: 24,
              blur: 18,
              fill: 0.08,
              borderColor: AppColors.a(AppColors.primary, 0.30),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'HOW IT WORKS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      RotationTransition(
                        turns: Tween<double>(begin: 0, end: 70 / 360)
                            .animate(CurvedAnimation(
                          parent: _demo,
                          curve: Curves.easeOutBack,
                        )),
                        child: Image.asset(
                          AppAssets.paddle,
                          width: 34,
                          height: 34,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _row(Icons.rotate_right, 'TAP A PADDLE TO TURN IT'),
                  _row(Icons.water_drop, 'DROPS FALL AND GET DEFLECTED'),
                  _row(Icons.science_rounded, 'FILL EACH TANK WITH ONE COLOR'),
                  const SizedBox(height: 4),
                  PrimaryButton(
                    label: 'GOT IT',
                    icon: Icons.check_rounded,
                    height: 48,
                    fontSize: 14,
                    radius: 14,
                    onTap: widget.onDismiss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
