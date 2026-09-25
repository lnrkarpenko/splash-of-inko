import 'dart:async';

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/droplet_dust_painter.dart';

/// Branded splash. Deliberately much darker than the menu and free of any
/// interactive control.
///
/// The hand-off to the menu is driven by a wall-clock [Timer], not by the
/// entry animation: emulators run with animator_duration_scale = 0, so an
/// AnimationController completes instantly there. The entry animation itself
/// is a single 1200 ms forward pass that settles — nothing loops, so the
/// window reaches idle and uiautomator can still dump it.
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _handoff;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: Curves.easeOutBack),
    );
    _intro.forward();
    _handoff = Timer(
      const Duration(milliseconds: GameConfig.loaderDurationMs),
      () {
        if (mounted) widget.onDone();
      },
    );
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDarkest,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.bgLoader),
                fit: BoxFit.cover,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.a(AppColors.bgDarkest, 0.92),
                  AppColors.a(AppColors.bgMid, 0.88),
                  AppColors.a(AppColors.bgBase, 0.86),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: DropletDustPainter()),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FadeTransition(
                    opacity: _fade,
                    child: ScaleTransition(
                      scale: _scale,
                      child: SizedBox(
                        width: 260,
                        height: 260,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: <Color>[
                                    AppColors.a(AppColors.primary, 0.35),
                                    AppColors.a(AppColors.primary, 0.0),
                                  ],
                                ),
                              ),
                              child: const SizedBox(width: 260, height: 260),
                            ),
                            Image.asset(
                              AppAssets.dropletCyan,
                              width: 132,
                              height: 132,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'SPLASH OF INKO',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 64,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'GUIDE THE FLOW',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4.0,
                            color: AppColors.a(AppColors.primary, 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 46),
                  AnimatedBuilder(
                    animation: _intro,
                    builder: (BuildContext context, Widget? child) {
                      return Container(
                        width: 180,
                        height: 4,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: AppColors.a(AppColors.textPrimary, 0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Container(
                          width: 180 * _intro.value,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: AppColors.ctaGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'LOADING...',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.4,
                      color: AppColors.a(AppColors.textPrimary, 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
