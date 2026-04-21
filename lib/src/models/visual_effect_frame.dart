import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Per-frame information provided to effects while painting.
@immutable
class VisualEffectFrame {
  /// Creates a frame description for the current paint pass.
  const VisualEffectFrame({
    required this.canvasSize,
    required this.paintRect,
    required this.fit,
    required this.timeSeconds,
    required this.pointerPosition,
    required this.pointerStrength,
  });

  /// Full size of the hosting widget.
  final Size canvasSize;

  /// Fitted effect bounds inside the widget after applying padding and [fit].
  final Rect paintRect;

  /// Fit used to derive [paintRect].
  final BoxFit fit;

  /// Elapsed time in seconds since the effect surface started animating.
  final double timeSeconds;

  /// Local pointer position within [paintRect].
  ///
  /// This may be outside the local effect size when the fitted paint rect
  /// extends beyond the clipped widget area.
  final Offset? pointerPosition;

  /// Smoothed interaction strength between `0` and `1`.
  final double pointerStrength;

  /// The local size available to the effect.
  Size get paintSize => paintRect.size;

  /// Whether the frame currently has active pointer influence.
  bool get hasPointer => pointerPosition != null && pointerStrength > 0;

  /// Computes a smooth radial influence for [position].
  ///
  /// This uses a `smootherstep` base curve and then applies the optional
  /// [easing] curve for additional artistic shaping.
  double radialInfluence(
    Offset position, {
    required double radius,
    Curve? easing,
  }) {
    final pointer = pointerPosition;
    if (pointer == null || pointerStrength <= 0 || radius <= 0) {
      return 0;
    }

    final distance = (position - pointer).distance;
    final normalized = 1 - (distance / radius);
    if (normalized <= 0) {
      return 0;
    }

    final shaped = smootherStep(normalized.clamp(0.0, 1.0));
    final curved = easing?.transform(shaped) ?? shaped;
    return curved * pointerStrength;
  }

  /// Returns a `smootherstep` interpolation for [value].
  static double smootherStep(double value) {
    final t = value.clamp(0.0, 1.0);
    return t * t * t * (t * (t * 6 - 15) + 10);
  }

  /// Returns a soft sine wave in the `0..1` range.
  static double sine01(double value) => 0.5 + 0.5 * math.sin(value);
}
