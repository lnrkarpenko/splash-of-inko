import 'game_config.dart';
import 'models.dart';

/// Deterministic flow engine. Pure Dart — no Flutter imports, no randomness.
///
/// A droplet enters a cell from above. A `right` paddle ("/") nudges it one
/// column to the right, a `left` paddle ("\") one column to the left; a nudge
/// that would leave the board is absorbed by the wall. Empty cells drop
/// straight through.
class FlowSimulator {
  const FlowSimulator._();

  /// Column occupied at the top of every row, plus the landing column.
  static List<int> pathFor(int startCol, Map<int, PaddleDir> grid) {
    final List<int> path = <int>[startCol];
    int col = startCol;
    for (int row = 0; row < GameConfig.rows; row++) {
      final PaddleDir? dir = grid[row * GameConfig.cols + col];
      if (dir != null) {
        final int next = col + (dir == PaddleDir.right ? 1 : -1);
        if (next >= 0 && next < GameConfig.cols) col = next;
      }
      path.add(col);
    }
    return path;
  }

  /// Drops leave the emitters round-robin so the board never looks empty.
  static List<DropRun> buildQueue(LevelSpec level, Map<int, PaddleDir> grid) {
    final List<int> remaining =
        level.emitters.map((EmitterSpec e) => e.count).toList();
    final List<List<int>> paths = level.emitters
        .map((EmitterSpec e) => pathFor(e.col, grid))
        .toList();

    final List<DropRun> queue = <DropRun>[];
    final int total = level.totalDrops;
    final int fallMs = GameConfig.rows * GameConfig.dropRowMs;

    while (queue.length < total) {
      for (int e = 0; e < level.emitters.length; e++) {
        if (remaining[e] <= 0) continue;
        remaining[e]--;
        final int index = queue.length;
        final int startMs = index * GameConfig.dropIntervalMs;
        queue.add(DropRun(
          index: index,
          emitterIndex: e,
          color: level.emitters[e].color,
          path: paths[e],
          startMs: startMs,
          landMs: startMs + fallMs,
        ));
      }
    }
    return queue;
  }

  static RoundResult simulate({
    required LevelSpec level,
    required List<PaddleDir> dirs,
    int turnsUsed = 0,
  }) {
    final Map<int, PaddleDir> grid = <int, PaddleDir>{};
    for (int i = 0; i < level.paddles.length; i++) {
      final PaddleSpec p = level.paddles[i];
      grid[p.row * GameConfig.cols + p.col] =
          i < dirs.length ? dirs[i] : p.dir;
    }

    final List<DropRun> queue = buildQueue(level, grid);
    final List<int> fills = List<int>.filled(level.tanks.length, 0);
    final List<bool> tainted = List<bool>.filled(level.tanks.length, false);

    int misses = 0;
    int resolved = queue.length;

    for (int i = 0; i < queue.length; i++) {
      final DropRun drop = queue[i];
      final int tank = GameConfig.tankOfCol[drop.landingCol];
      final TankSpec spec = level.tanks[tank];
      final bool fits = drop.color == spec.target && fills[tank] < spec.capacity;
      if (fits) {
        fills[tank]++;
      } else {
        misses++;
        tainted[tank] = true;
      }
      if (misses >= GameConfig.maxMisses) {
        resolved = i + 1;
        break;
      }
    }

    bool win = misses == 0;
    if (win) {
      for (int t = 0; t < level.tanks.length; t++) {
        if (tainted[t] || fills[t] < level.tanks[t].capacity) {
          win = false;
          break;
        }
      }
    }

    final int turnsLeft = level.turnBudget - turnsUsed;
    int stars = 0;
    if (win) {
      if (turnsLeft >= 2) {
        stars = 3;
      } else if (turnsLeft == 1) {
        stars = 2;
      } else {
        stars = 1;
      }
    }

    final int lastLand = resolved > 0 ? queue[resolved - 1].landMs : 0;

    return RoundResult(
      levelIndex: level.index,
      levelName: level.name,
      isWin: win,
      stars: stars,
      turnsUsed: turnsUsed,
      turnsLeft: turnsLeft < 0 ? 0 : turnsLeft,
      misses: misses,
      fills: fills,
      tainted: tainted,
      tanks: level.tanks,
      drops: queue,
      resolvedDrops: resolved,
      flowDurationMs: lastLand + GameConfig.resolveHoldMs,
    );
  }

  /// Applies a level's recorded solution to its starting layout.
  static List<PaddleDir> solvedDirs(LevelSpec level) {
    final List<PaddleDir> dirs =
        level.paddles.map((PaddleSpec p) => p.dir).toList();
    for (final int i in level.solution) {
      dirs[i] = flipDir(dirs[i]);
    }
    return dirs;
  }

  /// Debug-only guard: every shipped level must be winnable by its solution.
  static bool verifyAllLevels(List<LevelSpec> levels) {
    for (final LevelSpec level in levels) {
      final RoundResult solved = simulate(
        level: level,
        dirs: solvedDirs(level),
        turnsUsed: level.solution.length,
      );
      if (!solved.isWin) return false;
      if (level.solution.length > level.turnBudget) return false;
    }
    return true;
  }
}
