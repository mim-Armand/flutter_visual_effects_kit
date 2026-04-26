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

    final accent = applyOpacity(config.accentColor, config.opacity);
    final palette = resolveEffectPalette(config);
    final cellSize = resolveCellSize(config);
    final columns = math.max(1, (size.width / cellSize).round());
    final rows = math.max(1, (size.height / cellSize).round());
    final stepX = size.width / columns;
    final stepY = size.height / rows;
    final minStep = math.min(stepX, stepY);
    final baseFontSize = math.min(stepX, stepY) * 0.56;
    final time = frame.timeSeconds * config.animationSpeed;
    final anchors = buildPaletteAnchors(
      size: size,
      palette: palette,
      time: time,
      motionStrength: config.randomMotionStrength,
    );

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final baseCenter = Offset((column + 0.5) * stepX, (row + 0.5) * stepY);
        final noise = seededValue(config.randomSeed, column, row);
        final ambientOffset = resolveAmbientOffset(
          seed: config.randomSeed,
          x: column,
          y: row,
          z: 3,
          time: time,
          amplitudeX: stepX * config.randomMotionStrength * 0.12,
          amplitudeY: stepY * config.randomMotionStrength * 0.12,
        );
        final center = baseCenter + ambientOffset;
        final pointerInfluence = frame.radialInfluence(
          center,
          radius: config.interactionRadius,
          easing: config.easing,
        );
        final ripple = sampleRippleDisturbance(
          center: center,
          ripples: frame.ripples,
          time: time,
          minStep: minStep,
          config: config,
          displacementScale: 0.28,
          bandWidthScale: 0.9,
        );
        final influence = math.max(pointerInfluence, ripple.influence);

        final idle = VisualEffectFrame.sine01(
          time * 1.15 + noise * math.pi * 2 + row * 0.18 + column * 0.12,
        );
        final idleScale = lerpScalar(config.minScale, 1.0, 0.75 + idle * 0.25);
        final scale = lerpScalar(idleScale, config.maxScale, influence);
        final fontSize = baseFontSize * scale;
        final baseColor = samplePaletteColor(center, anchors);
        final color = mixColors(
          baseColor,
          accent,
          (influence * 0.38) + idle * 0.1,
        );
        final displacedCenter = center + ripple.offset;

        if (influence > 0.06) {
          context.paintMark(
            canvas,
            symbol: config.symbol,
            shape: config.shape,
            center: displacedCenter,
            fontSize: fontSize * 1.08,
            color: multiplyAlpha(accent, 0.14 + influence * 0.16),
            fontWeight: FontWeight.w700,
          );
        }

        context.paintMark(
          canvas,
          symbol: config.symbol,
          shape: config.shape,
          center: displacedCenter,
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w600,
        );
      }
    }
  }
}
