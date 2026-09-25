import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/flow_simulator.dart';
import 'game/levels.dart';
import 'game/models.dart';
import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/menu_screen.dart';
import 'theme.dart';

/// Every destination in the app. `gameover` is mandatory: without a distinct
/// result state the round never produces a separate frame.
enum Screen { loader, menu, levels, game, gameover }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Debug-only regression guard: each shipped level must still be winnable by
  // the solution recorded next to it. Stripped from release builds.
  assert(
    FlowSimulator.verifyAllLevels(kLevels),
    'A shipped level is no longer winnable by its recorded solution',
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const SplashOfInkoApp());
}

class SplashOfInkoApp extends StatelessWidget {
  const SplashOfInkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash of Inko',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AppShell(),
    );
  }
}

/// setState-driven state machine. No router: there are no deep links, and a
/// declarative router would only add a dependency.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Screen _screen = Screen.loader;
  int _currentLevel = 1;
  int _unlocked = 1;
  bool _showTutorial = false;
  bool _tutorialSeen = false;
  RoundResult? _lastResult;

  final List<int> _starsPerLevel = List<int>.filled(kLevels.length, 0);

  int get _totalStars =>
      _starsPerLevel.fold<int>(0, (int sum, int s) => sum + s);

  LevelSpec get _level => kLevels[(_currentLevel - 1).clamp(0, kLevels.length - 1)];

  void _go(Screen screen) => setState(() => _screen = screen);

  void _startLevel(int index, {bool tutorial = false}) {
    setState(() {
      _currentLevel = index.clamp(1, kLevels.length);
      _showTutorial = tutorial;
      _tutorialSeen = _tutorialSeen || tutorial;
      _screen = Screen.game;
    });
  }

  void _onRoundFinished(RoundResult result) {
    setState(() {
      if (result.isWin) {
        final int slot = result.levelIndex - 1;
        if (slot >= 0 && slot < _starsPerLevel.length) {
          _starsPerLevel[slot] = result.stars > _starsPerLevel[slot]
              ? result.stars
              : _starsPerLevel[slot];
        }
        final int next = result.levelIndex + 1;
        if (next > _unlocked && next <= kLevels.length) _unlocked = next;
      }
      _lastResult = result;
      _screen = Screen.gameover;
    });
  }

  Widget _buildScreen() {
    switch (_screen) {
      case Screen.loader:
        return LoaderScreen(
          key: const ValueKey<String>('loader'),
          onDone: () => _go(Screen.menu),
        );
      case Screen.menu:
        return MenuScreen(
          key: const ValueKey<String>('menu'),
          currentLevel: _currentLevel,
          stars: _totalStars,
          onPlay: () => _startLevel(
            _currentLevel,
            tutorial: !_tutorialSeen,
          ),
          onLevels: () => _go(Screen.levels),
          onTutorial: () => _startLevel(_currentLevel, tutorial: true),
        );
      case Screen.levels:
        return LevelSelectScreen(
          key: const ValueKey<String>('levels'),
          unlocked: _unlocked,
          starsPerLevel: _starsPerLevel,
          totalStars: _totalStars,
          onPick: (int index) => _startLevel(index),
          onBack: () => _go(Screen.menu),
        );
      case Screen.game:
        return GameScreen(
          key: ValueKey<String>('game_$_currentLevel'),
          level: _level,
          showTutorial: _showTutorial,
          onExit: () => _go(Screen.menu),
          onFinish: _onRoundFinished,
        );
      case Screen.gameover:
        final RoundResult? result = _lastResult;
        if (result == null) {
          return MenuScreen(
            key: const ValueKey<String>('menu_fallback'),
            currentLevel: _currentLevel,
            stars: _totalStars,
            onPlay: () => _startLevel(_currentLevel),
            onLevels: () => _go(Screen.levels),
            onTutorial: () => _startLevel(_currentLevel, tutorial: true),
          );
        }
        return GameOverScreen(
          key: ValueKey<String>('gameover_${result.levelIndex}'),
          result: result,
          hasNextLevel: result.levelIndex < kLevels.length,
          onPlayAgain: () => _startLevel(result.levelIndex),
          onNextLevel: () => _startLevel(result.levelIndex + 1),
          onMenu: () => _go(Screen.menu),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildScreen(),
    );
  }
}
