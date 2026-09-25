import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets.dart';
import '../game/flow_simulator.dart';
import '../game/game_config.dart';
import '../game/models.dart';
import '../theme.dart';
import '../widgets/drop_sprite.dart';
import '../widgets/flow_board.dart';
import '../widgets/glass_panel.dart';
import '../widgets/primary_button.dart';
import '../widgets/tank_gauge.dart';
import '../widgets/tutorial_overlay.dart';

/// Snapshot of the reservoirs at one instant of the flow animation.
class _FlowSnapshot {
  const _FlowSnapshot(this.fills, this.tainted, this.misses);

  final List<double> fills;
  final List<bool> tainted;
  final int misses;
}

/// The puzzle board with a floating action panel.
///
/// Two safety nets keep the round from stalling under an automated runner:
/// a long no-input timer (the board gets photographed first) and a short
/// timer armed by the first touch and re-armed by every touch after it, so a
/// human who keeps thinking is never cut off.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.level,
    required this.showTutorial,
    required this.onExit,
    required this.onFinish,
  });

  final LevelSpec level;
  final bool showTutorial;
  final VoidCallback onExit;
  final ValueChanged<RoundResult> onFinish;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late List<PaddleDir> _dirs;
  int _turnsUsed = 0;
  bool _flowing = false;
  bool _finished = false;
  bool _tutorialVisible = false;

  RoundResult? _result;
  AnimationController? _flow;
  Timer? _idleTimer;
  Timer? _engagedTimer;
  Timer? _tutorialTimer;

  @override
  void initState() {
    super.initState();
    _dirs = widget.level.paddles.map((PaddleSpec p) => p.dir).toList();
    _tutorialVisible = widget.showTutorial;
    if (_tutorialVisible) {
      _tutorialTimer = Timer(
        const Duration(milliseconds: GameConfig.tutorialAutoHideMs),
        _dismissTutorial,
      );
    }
    _idleTimer = Timer(
      const Duration(milliseconds: GameConfig.idleAutoFlowMs),
      _startFlow,
    );
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _engagedTimer?.cancel();
    _tutorialTimer?.cancel();
    _flow?.dispose();
    super.dispose();
  }

  void _dismissTutorial() {
    _tutorialTimer?.cancel();
    if (!mounted || !_tutorialVisible) return;
    setState(() => _tutorialVisible = false);
  }

  /// Every touch pushes the auto-release further out.
  void _registerInput() {
    _idleTimer?.cancel();
    _engagedTimer?.cancel();
    _engagedTimer = Timer(
      const Duration(milliseconds: GameConfig.engagedAutoFlowMs),
      _startFlow,
    );
  }

  void _onTapPaddle(int index) {
    if (_flowing || _turnsUsed >= widget.level.turnBudget) return;
    if (_tutorialVisible) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {
      // Haptics are optional; never let a missing vibrator break a turn.
    }
    setState(() {
      _dirs[index] = flipDir(_dirs[index]);
      _turnsUsed++;
    });
    _registerInput();
  }

  void _startFlow() {
    if (!mounted || _flowing || _finished) return;
    _idleTimer?.cancel();
    _engagedTimer?.cancel();
    _tutorialTimer?.cancel();

    final RoundResult result = FlowSimulator.simulate(
      level: widget.level,
      dirs: _dirs,
      turnsUsed: _turnsUsed,
    );
    final AnimationController controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: result.flowDurationMs),
    );
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) _finish();
    });

    setState(() {
      _tutorialVisible = false;
      _flowing = true;
      _result = result;
      _flow = controller;
    });
    controller.forward();
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    final RoundResult? result = _result;
    if (result != null) widget.onFinish(result);
  }

  double get _elapsedMs {
    final RoundResult? result = _result;
    final AnimationController? flow = _flow;
    if (result == null || flow == null) return 0;
    return flow.value * result.flowDurationMs;
  }

  List<ActiveDrop> _dropsAt(double t) {
    final RoundResult? result = _result;
    if (result == null) return const <ActiveDrop>[];
    final List<ActiveDrop> live = <ActiveDrop>[];
    for (int i = 0; i < result.resolvedDrops; i++) {
      final DropRun drop = result.drops[i];
      final double local = t - drop.startMs;
      if (local < 0) continue;
      final double progress = local / GameConfig.dropRowMs;
      if (progress >= GameConfig.rows) continue;
      final int row = progress.floor();
      final double frac = progress - row;
      final double col =
          drop.path[row] + (drop.path[row + 1] - drop.path[row]) * frac;
      live.add(ActiveDrop(color: drop.color, col: col, row: row + frac));
    }
    return live;
  }

  _FlowSnapshot _snapshotAt(double t) {
    final int tankCount = widget.level.tanks.length;
    final List<double> fills = List<double>.filled(tankCount, 0);
    final List<bool> tainted = List<bool>.filled(tankCount, false);
    final List<int> landed = List<int>.filled(tankCount, 0);
    int misses = 0;

    final RoundResult? result = _result;
    if (result == null) return _FlowSnapshot(fills, tainted, misses);

    for (int i = 0; i < result.resolvedDrops; i++) {
      final DropRun drop = result.drops[i];
      if (t < drop.landMs) break;
      final int tank = GameConfig.tankOfCol[drop.landingCol];
      final TankSpec spec = widget.level.tanks[tank];
      final bool fits =
          drop.color == spec.target && landed[tank] < spec.capacity;
      if (fits) {
        landed[tank]++;
        final double settle = ((t - drop.landMs) / 320).clamp(0.0, 1.0);
        fills[tank] += Curves.easeOut.transform(settle);
      } else {
        misses++;
        tainted[tank] = true;
      }
    }
    return _FlowSnapshot(fills, tainted, misses);
  }

  @override
  Widget build(BuildContext context) {
    final Listenable ticker = _flow ?? const AlwaysStoppedAnimation<double>(0);

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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.a(AppColors.bgBase, 0.80),
                  AppColors.a(AppColors.bgDeep, 0.88),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: AnimatedBuilder(
              animation: ticker,
              builder: (BuildContext context, Widget? child) {
                final double t = _elapsedMs;
                final _FlowSnapshot snap = _snapshotAt(t);
                return Column(
                  children: <Widget>[
                    _buildHeader(snap.misses),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 170),
                        child: LayoutBuilder(
                          builder:
                              (BuildContext context, BoxConstraints bounds) {
                            return _buildArena(bounds, t, snap);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 100,
            child: _buildControlBar(),
          ),
          if (_tutorialVisible) TutorialOverlay(onDismiss: _dismissTutorial),
        ],
      ),
    );
  }

  Widget _buildHeader(int misses) {
    final int turnsLeft = widget.level.turnBudget - _turnsUsed;
    return Container(
      height: 116,
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.a(AppColors.bgDarkest, 0.45),
        border: Border(
          bottom: BorderSide(color: AppColors.a(AppColors.textPrimary, 0.10)),
        ),
      ),
      child: Row(
        children: <Widget>[
          GlassIconButton(
            icon: Icons.arrow_back_rounded,
            semanticLabel: 'Back',
            onTap: widget.onExit,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'LEVEL ${widget.level.index}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.level.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: AppColors.a(AppColors.primary, 0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _counter(Icons.rotate_right, 'TURNS $turnsLeft', AppColors.gold),
              const SizedBox(height: 4),
              _counter(
                Icons.close_rounded,
                'MISS $misses/${GameConfig.maxMisses}',
                AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counter(IconData icon, String label, Color tint) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 18, color: tint),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: tint,
          ),
        ),
      ],
    );
  }

  Widget _buildArena(BoxConstraints bounds, double t, _FlowSnapshot snap) {
    const double frame = GameConfig.boardFrame;
    const double emitterH = 34;
    const double tankH = 68;
    const double tankBlock = tankH + 20;
    const double gaps = 18;

    final double widthCap =
        math.min(bounds.maxWidth - 32, GameConfig.boardMaxWidth);
    final double cellFromWidth =
        ((widthCap - 2 * frame) / GameConfig.cols).floorToDouble();
    final double heightBudget =
        bounds.maxHeight - emitterH - tankBlock - gaps - 2 * frame;
    final double cellFromHeight =
        (heightBudget / GameConfig.rows).floorToDouble();
    final double cell =
        math.max(30.0, math.min(cellFromWidth, cellFromHeight));
    final double innerW = cell * GameConfig.cols;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: innerW,
            height: emitterH,
            child: _buildEmitters(cell),
          ),
          const SizedBox(height: 8),
          FlowBoard(
            cell: cell,
            paddles: widget.level.paddles,
            dirs: _dirs,
            drops: _dropsAt(t),
            interactive: !_flowing && !_tutorialVisible,
            onTapPaddle: _onTapPaddle,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: innerW,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < widget.level.tanks.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    flex: GameConfig.tankFlex[i],
                    child: TankGauge(
                      spec: widget.level.tanks[i],
                      fill: snap.fills[i],
                      tainted: snap.tainted[i],
                      height: tankH,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmitters(double cell) {
    final Map<int, EmitterSpec> byCol = <int, EmitterSpec>{
      for (final EmitterSpec e in widget.level.emitters) e.col: e,
    };
    return Row(
      children: <Widget>[
        for (int c = 0; c < GameConfig.cols; c++)
          SizedBox(
            width: cell,
            child: byCol.containsKey(c)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${byCol[c]!.count}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          color: dropColorValue(byCol[c]!.color),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: cell * 0.46,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: <Color>[
                              AppColors.a(
                                dropColorValue(byCol[c]!.color),
                                0.95,
                              ),
                              AppColors.a(
                                dropColorValue(byCol[c]!.color),
                                0.45,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: cell * 0.46,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.a(AppColors.textPrimary, 0.15),
                        ),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }

  Widget _buildControlBar() {
    final int placed = _turnsUsed.clamp(0, widget.level.turnBudget);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.a(AppColors.bgDarkest, 0.55),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.a(AppColors.textPrimary, 0.10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'PADDLES SET $placed/${widget.level.turnBudget}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.a(AppColors.textPrimary, 0.6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _flowing ? 'FLOW IN MOTION' : 'TAP TO TURN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.a(AppColors.primary, 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: _flowing ? 'FLOWING' : 'DROP',
                icon: Icons.water_drop,
                height: 56,
                fontSize: 18,
                radius: 16,
                enabled: !_flowing,
                glow: AppColors.a(AppColors.secondary, 0.45),
                onTap: _startFlow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
