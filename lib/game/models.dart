// Pure data model for the flow puzzle. No Flutter imports on purpose so the
// simulator stays unit-testable.

enum DropColor { cyan, violet, gold }

enum PaddleDir { left, right }

PaddleDir flipDir(PaddleDir dir) =>
    dir == PaddleDir.left ? PaddleDir.right : PaddleDir.left;

class PaddleSpec {
  const PaddleSpec(this.row, this.col, this.dir);

  final int row;
  final int col;
  final PaddleDir dir;
}

class EmitterSpec {
  const EmitterSpec(this.col, this.count, this.color);

  final int col;
  final int count;
  final DropColor color;
}

class TankSpec {
  const TankSpec(this.target, this.capacity);

  final DropColor target;
  final int capacity;
}

class LevelSpec {
  const LevelSpec({
    required this.index,
    required this.name,
    required this.difficulty,
    required this.paddles,
    required this.emitters,
    required this.tanks,
    required this.turnBudget,
    required this.solution,
  });

  final int index;
  final String name;
  final String difficulty;

  /// Starting layout (already scrambled away from the solved layout).
  final List<PaddleSpec> paddles;
  final List<EmitterSpec> emitters;
  final List<TankSpec> tanks;
  final int turnBudget;

  /// Indices into [paddles] that must be flipped to win. Constructive by
  /// design: the level was authored from a solved layout, then scrambled.
  final List<int> solution;

  int get totalDrops =>
      emitters.fold<int>(0, (int sum, EmitterSpec e) => sum + e.count);
}

/// One droplet's full journey down the board.
class DropRun {
  const DropRun({
    required this.index,
    required this.emitterIndex,
    required this.color,
    required this.path,
    required this.startMs,
    required this.landMs,
  });

  final int index;
  final int emitterIndex;
  final DropColor color;

  /// Column occupied at the top of each row, plus the landing column.
  /// Length is rows + 1.
  final List<int> path;
  final int startMs;
  final int landMs;

  int get landingCol => path.last;
}

class RoundResult {
  const RoundResult({
    required this.levelIndex,
    required this.levelName,
    required this.isWin,
    required this.stars,
    required this.turnsUsed,
    required this.turnsLeft,
    required this.misses,
    required this.fills,
    required this.tainted,
    required this.tanks,
    required this.drops,
    required this.resolvedDrops,
    required this.flowDurationMs,
  });

  final int levelIndex;
  final String levelName;
  final bool isWin;
  final int stars;
  final int turnsUsed;
  final int turnsLeft;
  final int misses;
  final List<int> fills;
  final List<bool> tainted;
  final List<TankSpec> tanks;
  final List<DropRun> drops;

  /// Drops that actually played before the round was cut short.
  final int resolvedDrops;
  final int flowDurationMs;

  int get pureTanks {
    int pure = 0;
    for (int i = 0; i < tanks.length; i++) {
      if (!tainted[i] && fills[i] >= tanks[i].capacity) pure++;
    }
    return pure;
  }
}
