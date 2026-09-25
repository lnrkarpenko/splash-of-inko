/// Tunables for the flow puzzle. Pure Dart, no Flutter imports.
class GameConfig {
  const GameConfig._();

  /// Splash duration. Driven by a wall-clock Timer, never by an
  /// AnimationController (emulators run with animator_duration_scale = 0).
  static const int loaderDurationMs = 8000;

  /// Board geometry.
  static const int rows = 6;
  static const int cols = 5;
  static const double boardPad = 6;
  static const double boardBorder = 2;
  static const double boardFrame = boardPad + boardBorder;
  static const double boardMaxWidth = 380;

  /// Which tank a bottom-row column empties into.
  static const List<int> tankOfCol = <int>[0, 0, 1, 2, 2];

  /// Relative widths of the three tanks.
  static const List<int> tankFlex = <int>[2, 1, 2];

  /// Flow timings.
  static const int dropIntervalMs = 450;
  static const int dropRowMs = 260;
  static const int resolveHoldMs = 600;

  /// A round ends immediately once this many drops land in the wrong tank.
  static const int maxMisses = 3;

  /// Safety nets for the passive UI-test runner.
  /// No interaction at all -> auto-release after 40 s (the capture agent takes
  /// its first in-game shot around +22 s, so the board is photographed first).
  static const int idleAutoFlowMs = 40000;

  /// Once the player has touched the board, a much shorter window: every tap
  /// re-arms it, so a human who keeps thinking never gets cut off, while an
  /// automated tapper always reaches a result screen.
  static const int engagedAutoFlowMs = 9000;

  /// Tutorial overlay hides itself so it can never sit on top of a screenshot.
  static const int tutorialAutoHideMs = 2600;
}
