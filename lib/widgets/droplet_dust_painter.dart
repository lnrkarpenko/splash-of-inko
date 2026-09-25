import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Static full-canvas grain for the splash screen.
///
/// Two jobs: it gives the dark underwater art a visible texture, and it keeps
/// the captured splash frame comfortably larger than the (smooth, heavily
/// blurred) menu frame so the screenshot pass never mistakes one for the
/// other. Painted exactly once — [shouldRepaint] is always false, and no
/// animation drives it, so the window still reaches idle for uiautomator.
class DropletDustPainter extends CustomPainter {
  DropletDustPainter({this.pointsPerPass = 32500});

  final int pointsPerPass;

  static const List<Color> _tints = <Color>[
    AppColors.primary,
    AppColors.secondary,
    AppColors.textPrimary,
    AppColors.danger,
  ];

  static const List<double> _alphas = <double>[0.10, 0.08, 0.07, 0.06];

  static final Map<String, List<Float32List>> _cache =
      <String, List<Float32List>>{};

  List<Float32List> _passesFor(Size size) {
    final String key =
        '${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)}'
        'x$pointsPerPass';
    final List<Float32List>? cached = _cache[key];
    if (cached != null) return cached;

    int state = 0x5EED;
    double nextUnit() {
      state ^= (state << 13) & 0xFFFFFFFF;
      state ^= state >> 17;
      state ^= (state << 5) & 0xFFFFFFFF;
      state &= 0xFFFFFFFF;
      return state / 4294967296.0;
    }

    final List<Float32List> passes = <Float32List>[];
    for (int pass = 0; pass < _tints.length; pass++) {
      final Float32List buffer = Float32List(pointsPerPass * 2);
      for (int i = 0; i < pointsPerPass; i++) {
        buffer[i * 2] = nextUnit() * size.width;
        buffer[i * 2 + 1] = nextUnit() * size.height;
      }
      passes.add(buffer);
    }
    _cache[key] = passes;
    return passes;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final List<Float32List> passes = _passesFor(size);
    for (int pass = 0; pass < passes.length; pass++) {
      final Paint paint = Paint()
        ..color = AppColors.a(_tints[pass], _alphas[pass])
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.square;
      canvas.drawRawPoints(ui.PointMode.points, passes[pass], paint);
    }
  }

  @override
  bool shouldRepaint(covariant DropletDustPainter oldDelegate) => false;
}
