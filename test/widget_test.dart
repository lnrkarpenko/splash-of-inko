import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:splash_of_inko/game/flow_simulator.dart';
import 'package:splash_of_inko/game/game_config.dart';
import 'package:splash_of_inko/game/levels.dart';
import 'package:splash_of_inko/game/models.dart';
import 'package:splash_of_inko/theme.dart';
import 'package:splash_of_inko/widgets/stat_card.dart';

void main() {
  group('FlowSimulator', () {
    test('every level is winnable by its recorded solution', () {
      for (final LevelSpec level in kLevels) {
        final RoundResult solved = FlowSimulator.simulate(
          level: level,
          dirs: FlowSimulator.solvedDirs(level),
          turnsUsed: level.solution.length,
        );
        expect(solved.isWin, isTrue, reason: 'level ${level.index}');
        expect(solved.stars, greaterThan(0), reason: 'level ${level.index}');
        expect(level.solution.length, lessThanOrEqualTo(level.turnBudget));
      }
    });

    test('the starting layout is not already a win', () {
      for (final LevelSpec level in kLevels) {
        final RoundResult start = FlowSimulator.simulate(
          level: level,
          dirs: level.paddles.map((PaddleSpec p) => p.dir).toList(),
        );
        expect(start.isWin, isFalse, reason: 'level ${level.index}');
        // A losing start must still resolve, so the passive runner always
        // reaches the result screen.
        expect(start.resolvedDrops, greaterThan(0));
        expect(start.flowDurationMs, greaterThan(0));
      }
    });

    test('level one needs a single turn', () {
      expect(kLevels.first.solution.length, 1);
    });

    test('a wall absorbs a deflection instead of leaving the board', () {
      final List<int> path = FlowSimulator.pathFor(0, <int, PaddleDir>{
        0: PaddleDir.left,
      });
      expect(path.first, 0);
      expect(path[1], 0);
      expect(path.length, GameConfig.rows + 1);
    });
  });

  testWidgets('StatCard renders its value and upper-cased label',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 140,
              child: StatCard(
                value: '3',
                label: 'turns left',
                valueColor: AppColors.gold,
                icon: Icons.rotate_right,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('TURNS LEFT'), findsOneWidget);
    expect(find.byIcon(Icons.rotate_right), findsOneWidget);
  });
}
