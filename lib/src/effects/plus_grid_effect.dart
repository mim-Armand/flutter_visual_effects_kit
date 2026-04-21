import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';
import '../models/visual_effect_frame.dart';
import '../rendering/visual_effect_drawing_context.dart';
import 'effect_support.dart';
import 'visual_effect.dart';

/// A polished grid of symbols that enlarges smoothly near the pointer.
class PlusGridEffect extends VisualEffect {
  /// Creates the plus grid effect.
  const PlusGridEffect();

  @override
  String get name => 'plusGrid';

  @override
  String get displayName => 'Plus Grid';

  @override
  String get description =>
      'A responsive grid of symbols with premium hover scaling.';

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
    final cellSize = resolveCellSize(config);
    final columns = math.max(1, (size.width / cellSize).round());
    final rows = math.max(1, (size.height / cellSize).round());
    final stepX = size.width / columns;
    final stepY = size.height / rows;
    final baseFontSize = math.min(stepX, stepY) * 0.56;
    final time = frame.timeSeconds * config.animationSpeed;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final center = Offset((column + 0.5) * stepX, (row + 0.5) * stepY);
        final noise = seededValue(config.randomSeed, column, row);
        final influence = frame.radialInfluence(
          center,
          radius: config.interactionRadius,
          easing: config.easing,
        );

        final idle = VisualEffectFrame.sine01(
          time * 1.15 + noise * math.pi * 2 + row * 0.18 + column * 0.12,
        );
        final idleScale = lerpScalar(config.minScale, 1.0, 0.75 + idle * 0.25);
        final scale = lerpScalar(idleScale, config.maxScale, influence);
        final fontSize = baseFontSize * scale;
        final color = mixColors(
          foreground,
          accent,
          (influence * 0.9) + idle * 0.08,
        );

        if (influence > 0.06) {
          context.paintSymbol(
            canvas,
            symbol: config.symbol,
            center: center,
            fontSize: fontSize * 1.08,
            color: accent.withAlpha(
              ((0.14 + influence * 0.16) * 255).round().clamp(0, 255),
            ),
            fontWeight: FontWeight.w700,
          );
        }

        context.paintSymbol(
          canvas,
          symbol: config.symbol,
          center: center,
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w600,
        );
      }
    }
  }
}
