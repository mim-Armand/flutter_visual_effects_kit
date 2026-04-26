import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';
import '../models/visual_effect_frame.dart';
import '../rendering/visual_effect_drawing_context.dart';
import 'effect_support.dart';
import 'visual_effect.dart';

/// A soft field of animated symbols that reacts to nearby pointer movement.
class DotFieldEffect extends VisualEffect {
  /// Creates the dot field effect.
  const DotFieldEffect();

  @override
  String get name => 'dotField';

  @override
  String get displayName => 'Dot Field';

  @override
  String get description =>
      'A calm particle-like field of symbols with subtle reactive highlights.';

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
    final cellSize = resolveCellSize(config) * 0.94;
    final columns = math.max(1, (size.width / cellSize).round());
    final rows = math.max(1, (size.height / cellSize).round());
    final stepX = size.width / columns;
    final stepY = size.height / rows;
    final minStep = math.min(stepX, stepY);
    final time = frame.timeSeconds * config.animationSpeed;
    final anchors = buildPaletteAnchors(
      size: size,
      palette: palette,
      time: time,
      motionStrength: config.randomMotionStrength,
    );
    final baseFontSize = minStep * 0.34;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final baseCenter = Offset((column + 0.5) * stepX, (row + 0.5) * stepY);
        final jitterX =
            centeredNoise(config.randomSeed, column, row) * stepX * 0.16;
        final jitterY =
            centeredNoise(config.randomSeed, column, row, 1) * stepY * 0.16;
        final ambientOffset = resolveAmbientOffset(
          seed: config.randomSeed,
          x: column,
          y: row,
          z: 4,
          time: time,
          amplitudeX: stepX * config.randomMotionStrength * 0.18,
          amplitudeY: stepY * config.randomMotionStrength * 0.2,
        );
        final center = baseCenter.translate(jitterX, jitterY) + ambientOffset;
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
          displacementScale: 0.36,
        );
        final influence = math.max(pointerInfluence, ripple.influence);
        final noise = seededValue(config.randomSeed, column, row, 2);
        final pulse = sine01(
          time * 1.4 + noise * math.pi * 2 + column * 0.14 + row * 0.19,
        );
        final offsetY = centeredNoise(config.randomSeed, column, row, 3) *
            stepY *
            0.06 *
            (0.65 + pulse * 0.35);
        final animatedCenter = center.translate(0, offsetY) + ripple.offset;
        final idleScale = lerpScalar(config.minScale, 1.0, 0.68 + pulse * 0.32);
        final scale = lerpScalar(idleScale, config.maxScale * 0.72, influence);
        final fontSize = baseFontSize *
            (0.92 + noise * 0.3) *
            lerpScalar(0.96, 1.18, pulse) *
            scale;
        final baseColor = samplePaletteColor(animatedCenter, anchors);
        final color = mixColors(
          multiplyAlpha(baseColor, 0.72 + pulse * 0.18),
          accent,
          influence * 0.42,
        );

        if (influence > 0.08) {
          context.paintMark(
            canvas,
            symbol: config.symbol,
            shape: config.shape,
            center: animatedCenter,
            fontSize: fontSize * 1.4,
            color: multiplyAlpha(accent, 0.08 + influence * 0.12),
            fontWeight: FontWeight.w500,
          );
        }

        context.paintMark(
          canvas,
          symbol: config.symbol,
          shape: config.shape,
          center: animatedCenter,
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w500,
        );
      }
    }
  }
}
