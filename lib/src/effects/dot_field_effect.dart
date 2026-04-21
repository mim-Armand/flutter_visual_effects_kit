import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';
import '../models/visual_effect_frame.dart';
import '../rendering/visual_effect_drawing_context.dart';
import 'effect_support.dart';
import 'visual_effect.dart';

/// A soft field of animated dots that reacts to nearby pointer movement.
class DotFieldEffect extends VisualEffect {
  /// Creates the dot field effect.
  const DotFieldEffect();

  @override
  String get name => 'dotField';

  @override
  String get displayName => 'Dot Field';

  @override
  String get description =>
      'A calm particle-like field with subtle reactive highlights.';

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
    final cellSize = resolveCellSize(config) * 0.94;
    final columns = math.max(1, (size.width / cellSize).round());
    final rows = math.max(1, (size.height / cellSize).round());
    final stepX = size.width / columns;
    final stepY = size.height / rows;
    final time = frame.timeSeconds * config.animationSpeed;
    final paint = Paint()..isAntiAlias = true;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final baseCenter = Offset((column + 0.5) * stepX, (row + 0.5) * stepY);
        final jitterX =
            centeredNoise(config.randomSeed, column, row) * stepX * 0.16;
        final jitterY =
            centeredNoise(config.randomSeed, column, row, 1) * stepY * 0.16;
        final center = baseCenter.translate(jitterX, jitterY);
        final influence = frame.radialInfluence(
          center,
          radius: config.interactionRadius,
          easing: config.easing,
        );
        final noise = seededValue(config.randomSeed, column, row, 2);
        final pulse = sine01(
          time * 1.4 + noise * math.pi * 2 + column * 0.14 + row * 0.19,
        );
        final offsetY = centeredNoise(config.randomSeed, column, row, 3) *
            stepY *
            0.06 *
            pulse;
        final animatedCenter = center.translate(0, offsetY);
        final radius = math.min(stepX, stepY) *
            (0.08 + noise * 0.06) *
            lerpScalar(0.95, 1.35, pulse);
        final scale = lerpScalar(1.0, config.maxScale * 0.72, influence);
        paint.color = mixColors(
          foreground.withAlpha(
            ((0.68 + pulse * 0.18) * 255).round().clamp(0, 255),
          ),
          accent,
          influence * 0.88,
        );

        if (influence > 0.08) {
          canvas.drawCircle(
            animatedCenter,
            radius * scale * 1.85,
            Paint()
              ..isAntiAlias = true
              ..color = accent.withAlpha(
                ((0.08 + influence * 0.12) * 255).round().clamp(0, 255),
              ),
          );
        }

        canvas.drawCircle(animatedCenter, radius * scale, paint);
      }
    }
  }
}
