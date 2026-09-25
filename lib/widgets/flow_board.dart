import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/models.dart';
import '../theme.dart';
import 'drop_sprite.dart';

/// A droplet currently in flight, in fractional board coordinates.
class ActiveDrop {
  const ActiveDrop({required this.color, required this.col, required this.row});

  final DropColor color;
  final double col;
  final double row;
}

/// The 5x6 puzzle grid: guide rails, paddles and droplets in flight.
///
/// Geometry follows the frame rule — the parent's padding and border are
/// subtracted before the cell size is derived, so tiles can never spill past
/// the rounded edge.
class FlowBoard extends StatelessWidget {
  const FlowBoard({
    super.key,
    required this.cell,
    required this.paddles,
    required this.dirs,
    required this.drops,
    required this.interactive,
    required this.onTapPaddle,
  });

  final double cell;
  final List<PaddleSpec> paddles;
  final List<PaddleDir> dirs;
  final List<ActiveDrop> drops;
  final bool interactive;
  final ValueChanged<int> onTapPaddle;

  @override
  Widget build(BuildContext context) {
    final double innerW = cell * GameConfig.cols;
    final double innerH = cell * GameConfig.rows;
    const double frame = GameConfig.boardFrame;

    return Container(
      width: innerW + frame * 2,
      height: innerH + frame * 2,
      padding: const EdgeInsets.all(GameConfig.boardPad),
      decoration: BoxDecoration(
        color: AppColors.a(AppColors.textPrimary, 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.a(AppColors.primary, 0.30),
          width: GameConfig.boardBorder,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.a(AppColors.primary, 0.18),
            blurRadius: 28,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: innerW,
          height: innerH,
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: CustomPaint(painter: _GridPainter(cell))),
              for (int i = 0; i < paddles.length; i++)
                Positioned(
                  left: paddles[i].col * cell,
                  top: paddles[i].row * cell,
                  width: cell,
                  height: cell,
                  child: _PaddleTile(
                    dir: i < dirs.length ? dirs[i] : paddles[i].dir,
                    cell: cell,
                    enabled: interactive,
                    onTap: () => onTapPaddle(i),
                  ),
                ),
              for (final ActiveDrop drop in drops)
                Positioned(
                  left: (drop.col + 0.5) * cell - cell * 0.42,
                  top: (drop.row + 0.5) * cell - cell * 0.42,
                  width: cell * 0.84,
                  height: cell * 0.84,
                  child: Center(
                    child: DropSprite(color: drop.color, size: cell * 0.44),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.cell);

  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.a(AppColors.textPrimary, 0.06)
      ..strokeWidth = 1;
    for (int c = 1; c < GameConfig.cols; c++) {
      final double x = c * cell;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int r = 1; r < GameConfig.rows; r++) {
      final double y = r * cell;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.cell != cell;
}

/// One rotatable guide. The whole cell is the tap target (>= 48 dp).
class _PaddleTile extends StatelessWidget {
  const _PaddleTile({
    required this.dir,
    required this.cell,
    required this.enabled,
    required this.onTap,
  });

  final PaddleDir dir;
  final double cell;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double bar = cell * 0.72;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.62,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedRotation(
              turns: dir == PaddleDir.right ? -35 / 360 : 35 / 360,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Image.asset(
                AppAssets.paddle,
                width: bar,
                height: bar,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
