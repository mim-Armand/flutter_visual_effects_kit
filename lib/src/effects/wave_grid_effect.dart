import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';
import '../models/visual_effect_frame.dart';
import '../rendering/visual_effect_drawing_context.dart';
import 'effect_support.dart';
import 'visual_effect.dart';

/// A subtle animated grid of capsules that flows like a moving wave field.
class WaveGridEffect extends VisualEffect {
  /// Creates the wave grid effect.
  const WaveGridEffect();

  @override
  String get name => 'waveGrid';

  @override
  String get displayName => 'Wave Grid';

  @override
  String get description =>
      'A restrained wave surface with optional pointer disturbance.';

  @override
  void paint(
    Canvas canvas,
    VisualEffectConfig config,
    VisualEffectFrame frame,
    VisualEffectDrawingContext context,
  ) {
    final size = frame.paintSize;
    if (size.isEmpty) {
      return;
    }

    final foreground = applyOpacity(config.foregroundColor, config.opacity);
    final accent = applyOpacity(config.accentColor, config.opacity);
    final cellSize = resolveCellSize(config) * 1.08;
    final columns = math.max(1, (size.width / cellSize).round());
    final rows = math.max(1, (size.height / cellSize).round());
    final stepX = size.width / columns;
    final stepY = size.height / rows;
    final time = frame.timeSeconds * config.animationSpeed;
    final paint = Paint()..isAntiAlias = true;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final center = Offset((column + 0.5) * stepX, (row + 0.5) * stepY);
        final nx = column / math.max(1, columns - 1);
        final ny = row / math.max(1, rows - 1);
        final noise = seededValue(config.randomSeed, column, row);
        final wave = math.sin((nx * 8.5) + (time * 1.35) + noise * 2.4) +
            math.cos((ny * 7.2) - (time * 1.1) + noise * 1.6);
        final baseOffset = wave * stepY * 0.11;
        final influence = frame.radialInfluence(
          center,
          radius: config.interactionRadius * 1.12,
          easing: config.easing,
        );
        final pointer = frame.pointerPosition;
        final distance = pointer == null ? 0.0 : (center - pointer).distance;
        final disturbance = pointer == null
            ? 0.0
            : math.sin(distance * 0.08 - time * 5.2) * influence * stepY * 0.38;

        final animatedCenter = center.translate(0, baseOffset + disturbance);
        final width = stepX * 0.38 * lerpScalar(0.9, 1.35, influence);
        final height =
            stepY * 0.12 * lerpScalar(0.8, config.maxScale * 0.68, influence);
        final rect = Rect.fromCenter(
          center: animatedCenter,
          width: width,
          height: math.max(2.4, height),
        );
        final radius = Radius.circular(rect.height);
        final shimmer = sine01(time * 1.2 + noise * math.pi * 2);
        paint.color = mixColors(
          foreground.withAlpha(
            ((0.48 + shimmer * 0.2) * 255).round().clamp(0, 255),
          ),
          accent,
          (influence * 0.9) + (shimmer * 0.08),
        );

        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
      }
    }
  }
}
