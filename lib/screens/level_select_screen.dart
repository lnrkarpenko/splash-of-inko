import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/levels.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/drop_sprite.dart';
import '../widgets/glass_panel.dart';

/// Scheme picker. Reached from the menu's secondary row and from the result
/// screen — never on the primary play path, so the capture agent is never
/// parked here.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({
    super.key,
    required this.unlocked,
    required this.starsPerLevel,
    required this.totalStars,
    required this.onPick,
    required this.onBack,
  });

  final int unlocked;
  final List<int> starsPerLevel;
  final int totalStars;
  final ValueChanged<int> onPick;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
              gradient: RadialGradient(
                center: const Alignment(0, -0.8),
                radius: 1.1,
                colors: <Color>[
                  AppColors.a(AppColors.secondary, 0.34),
                  AppColors.a(AppColors.bgBase, 0.90),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.a(AppColors.bgBase, 0.72),
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Container(
                  height: 116,
                  padding: const EdgeInsets.fromLTRB(16, 44, 16, 0),
                  decoration: BoxDecoration(
                    color: AppColors.a(AppColors.bgDarkest, 0.45),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.a(AppColors.textPrimary, 0.10),
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      GlassIconButton(
                        icon: Icons.arrow_back_rounded,
                        semanticLabel: 'Back',
                        onTap: onBack,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'CHOOSE SCHEME',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      GlassPill(
                        label: 'STARS $totalStars',
                        icon: Icons.star_rounded,
                        tint: AppColors.gold,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    children: <Widget>[
                      for (final LevelSpec level in kLevels)
                        _LevelCard(
                          level: level,
                          locked: level.index > unlocked,
                          stars: level.index <= starsPerLevel.length
                              ? starsPerLevel[level.index - 1]
                              : 0,
                          onTap: () => onPick(level.index),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.locked,
    required this.stars,
    required this.onTap,
  });

  final LevelSpec level;
  final bool locked;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String number = level.index.toString().padLeft(2, '0');

    return Opacity(
      opacity: locked ? 0.42 : 1.0,
      child: Material(
        color: AppColors.a(AppColors.textPrimary, 0.06),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: locked ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.a(AppColors.primary, 0.28)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (final TankSpec tank in level.tanks)
                      Container(
                        width: 16,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              AppColors.a(dropColorValue(tank.target), 0.25),
                              AppColors.a(dropColorValue(tank.target), 0.85),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.a(
                              dropColorValue(tank.target),
                              0.55,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (locked)
                  Icon(
                    Icons.lock_rounded,
                    size: 20,
                    color: AppColors.a(AppColors.textPrimary, 0.5),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 0; i < 3; i++)
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: i < stars
                              ? AppColors.gold
                              : AppColors.a(AppColors.textPrimary, 0.22),
                        ),
                    ],
                  ),
                const SizedBox(height: 6),
                Text(
                  level.difficulty,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: AppColors.a(AppColors.textPrimary, 0.55),
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
