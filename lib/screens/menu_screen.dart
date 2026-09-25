import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/levels.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/drop_sprite.dart';
import '../widgets/glass_panel.dart';
import '../widgets/primary_button.dart';
import '../widgets/stat_card.dart';

/// Bottom-sheet menu: full-bleed water art up top, frosted control sheet below.
class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.currentLevel,
    required this.stars,
    required this.onPlay,
    required this.onLevels,
    required this.onTutorial,
  });

  final int currentLevel;
  final int stars;
  final VoidCallback onPlay;
  final VoidCallback onLevels;
  final VoidCallback onTutorial;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  late final Animation<double> _sheet;
  bool _sound = true;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _sheet = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0, 0.12, curve: Curves.easeOutCubic),
    );
    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  /// One slow settling drift, then the droplet stays put — nothing repeats.
  Widget _drifting(double phase, Widget child) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (BuildContext context, Widget? inner) {
        final double t = (_enter.value + phase).clamp(0.0, 1.0);
        final double drift = 6 * Curves.easeInOut.transform(t) - 3;
        return Transform.translate(offset: Offset(0, drift), child: inner);
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.bgMenu),
                fit: BoxFit.cover,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const <double>[0.0, 0.34, 1.0],
                colors: <Color>[
                  AppColors.a(AppColors.bgBase, 0.62),
                  AppColors.a(AppColors.bgBase, 0.10),
                  AppColors.a(AppColors.bgDeep, 0.30),
                ],
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.20,
            left: 32,
            child: _drifting(
              0.0,
              const DropSprite(color: DropColor.cyan, size: 46),
            ),
          ),
          Positioned(
            top: size.height * 0.28,
            right: 36,
            child: _drifting(
              0.25,
              const DropSprite(color: DropColor.violet, size: 34),
            ),
          ),
          Positioned(
            top: size.height * 0.38,
            left: size.width * 0.44,
            child: _drifting(
              0.5,
              const DropSprite(color: DropColor.gold, size: 28),
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 44, 20, 0),
                  child: Row(
                    children: <Widget>[
                      GlassPill(
                        label: 'LEVEL ${widget.currentLevel}/${kLevels.length}',
                        icon: Icons.water_drop,
                        tint: AppColors.primary,
                      ),
                      const Spacer(),
                      GlassIconButton(
                        icon: _sound
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        semanticLabel: 'Sound',
                        onTap: () => setState(() => _sound = !_sound),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(_sheet),
                  child: FadeTransition(opacity: _sheet, child: _buildSheet()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          decoration: BoxDecoration(
            color: AppColors.a(AppColors.bgBase, 0.72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: AppColors.a(AppColors.textPrimary, 0.10)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.a(AppColors.textPrimary, 0.22),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SPLASH OF INKO',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'SORT THE COLORED FLOW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.6,
                  color: AppColors.a(AppColors.primary, 0.85),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatCard(
                      value: '${widget.currentLevel}',
                      label: 'level',
                      valueColor: AppColors.primary,
                      icon: Icons.water_drop,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      value: '${kLevels.length}',
                      label: 'schemes',
                      valueColor: AppColors.secondary,
                      icon: Icons.grid_view_rounded,
                    ),
                  ),
                  if (widget.stars > 0) ...<Widget>[
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        value: '${widget.stars}',
                        label: 'stars',
                        valueColor: AppColors.gold,
                        icon: Icons.star_rounded,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'ROTATE PADDLES THEN DROP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                  color: AppColors.a(AppColors.textPrimary, 0.5),
                ),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'PLAY NOW',
                icon: Icons.play_arrow_rounded,
                onTap: widget.onPlay,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: SecondaryButton(
                      label: 'LEVELS',
                      icon: Icons.grid_view_rounded,
                      onTap: widget.onLevels,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: 'HOW TO PLAY',
                      icon: Icons.help_outline_rounded,
                      onTap: widget.onTutorial,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
