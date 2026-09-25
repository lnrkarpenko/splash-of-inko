import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/drop_sprite.dart';
import '../widgets/primary_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/tank_gauge.dart';

/// Round result. Reached from [GameScreen] through the app's `gameover` state.
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.result,
    required this.hasNextLevel,
    required this.onPlayAgain,
    required this.onNextLevel,
    required this.onMenu,
  });

  final RoundResult result;
  final bool hasNextLevel;
  final VoidCallback onPlayAgain;
  final VoidCallback onNextLevel;
  final VoidCallback onMenu;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Animation<double> _starAt(int index) {
    final double begin = (index * 0.2).clamp(0.0, 0.6);
    return Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _enter,
        curve: Interval(begin, begin + 0.4, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RoundResult result = widget.result;
    final bool won = result.isWin;
    final Color accent = won ? AppColors.primary : AppColors.danger;

    final List<Widget> stats = <Widget>[
      if (result.turnsLeft > 0)
        StatCard(
          value: '${result.turnsLeft}',
          label: 'turns left',
          valueColor: AppColors.gold,
          icon: Icons.rotate_right,
        ),
      if (result.pureTanks > 0)
        StatCard(
          value: '${result.pureTanks}/${result.tanks.length}',
          label: 'pure',
          valueColor: AppColors.primary,
          icon: Icons.water_drop,
        ),
      if (result.misses > 0)
        StatCard(
          value: '${result.misses}',
          label: 'misses',
          valueColor: AppColors.danger,
          icon: Icons.close_rounded,
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.bgGame),
                fit: BoxFit.cover,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.a(AppColors.bgDeep, 0.90),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.85),
                radius: 1.0,
                colors: <Color>[
                  AppColors.a(accent, won ? 0.30 : 0.12),
                  AppColors.a(AppColors.bgDeep, 0.0),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 12),
                  Text(
                    won ? 'YOU WON!' : 'NO LUCK!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    won ? 'PURE FLOW ACHIEVED' : 'THE COLORS MIXED UP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.4,
                      color: AppColors.a(AppColors.textPrimary, 0.6),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 0; i < 3; i++)
                        ScaleTransition(
                          scale: _starAt(i),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.star_rounded,
                              size: 34,
                              color: i < result.stars
                                  ? AppColors.gold
                                  : AppColors.a(AppColors.textPrimary, 0.18),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildTanks(result),
                  if (stats.length >= 2) ...<Widget>[
                    const SizedBox(height: 22),
                    Row(
                      children: <Widget>[
                        for (int i = 0; i < stats.length; i++) ...<Widget>[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(child: stats[i]),
                        ],
                      ],
                    ),
                  ],
                  const Spacer(),
                  PrimaryButton(
                    label: 'DROP AGAIN',
                    icon: Icons.replay_rounded,
                    onTap: widget.onPlayAgain,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      if (won && widget.hasNextLevel) ...<Widget>[
                        Expanded(
                          child: SecondaryButton(
                            label: 'NEXT LEVEL',
                            icon: Icons.arrow_forward_rounded,
                            tint: AppColors.primary,
                            onTap: widget.onNextLevel,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: SecondaryButton(
                          label: 'MENU',
                          icon: Icons.home_rounded,
                          onTap: widget.onMenu,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTanks(RoundResult result) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < result.tanks.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            flex: GameConfig.tankFlex[i],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TankGauge(
                  spec: result.tanks[i],
                  fill: result.fills[i].toDouble(),
                  tainted: result.tainted[i],
                  height: 76,
                ),
                const SizedBox(height: 6),
                Text(
                  !result.tainted[i] &&
                          result.fills[i] >= result.tanks[i].capacity
                      ? '✓'
                      : '✗',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: !result.tainted[i] &&
                            result.fills[i] >= result.tanks[i].capacity
                        ? AppColors.primary
                        : AppColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dropColorValue(result.tanks[i].target),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
