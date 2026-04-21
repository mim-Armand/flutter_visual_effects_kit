import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';

/// Resolves a practical grid spacing from the shared [config].
double resolveCellSize(VisualEffectConfig config) {
  final density = config.density.clamp(0.35, 3.5);
  return (config.baseCellSize / density).clamp(10.0, 96.0);
}

/// Linearly interpolates between [a] and [b].
double lerpScalar(double a, double b, double t) {
  final clamped = t.clamp(0.0, 1.0);
  return a + (b - a) * clamped;
}

/// Mixes [a] and [b] by [t].
Color mixColors(Color a, Color b, double t) {
  return Color.lerp(a, b, t.clamp(0.0, 1.0))!;
}

/// Applies a multiplicative opacity factor to [color].
Color applyOpacity(Color color, double opacity) {
  final alpha = ((color.a * opacity) * 255.0).round() & 0xff;
  return color.withAlpha(alpha);
}

/// Returns a deterministic pseudo-random value in the `0..1` range.
double seededValue(int seed, int x, int y, [int z = 0]) {
  var hash = seed & 0x7fffffff;
  hash = (hash ^ (x * 374761393)) & 0x7fffffff;
  hash = (hash ^ (y * 668265263)) & 0x7fffffff;
  hash = (hash ^ (z * 2147483647)) & 0x7fffffff;
  hash = (hash ^ (hash >> 13)) & 0x7fffffff;
  hash = (hash * 1274126177) & 0x7fffffff;
  hash = (hash ^ (hash >> 16)) & 0x7fffffff;
  return hash / 0x7fffffff;
}

/// Returns a deterministic pseudo-random value in the `-1..1` range.
double centeredNoise(int seed, int x, int y, [int z = 0]) {
  return seededValue(seed, x, y, z) * 2 - 1;
}

/// Fits a square procedural scene into [bounds] using [fit].
Rect resolveFitRect(Rect bounds, BoxFit fit) {
  if (bounds.isEmpty) {
    return bounds;
  }

  const sourceSize = Size.square(1);
  final fittedSizes = applyBoxFit(fit, sourceSize, bounds.size);
  return Alignment.center.inscribe(fittedSizes.destination, bounds);
}

/// Returns a sine wave remapped into the `0..1` range.
double sine01(double value) => 0.5 + 0.5 * math.sin(value);
