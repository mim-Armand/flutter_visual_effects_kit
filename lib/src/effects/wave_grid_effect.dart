import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';
import '../models/visual_effect_frame.dart';
import '../rendering/visual_effect_drawing_context.dart';
import 'effect_support.dart';
import 'visual_effect.dart';

/// A subtle animated grid of symbols that flows like a moving wave field.
class WaveGridEffect extends VisualEffect {
  /// Creates the wave grid effect.
  const WaveGridEffect();

  @override
  String get name => 'waveGrid';

  @override
  String get displayName => 'Wave Grid';

  @override
  String get description =>
      'A restrained wave surface of symbols with optional pointer disturbance.';

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
    final cellSize = resolveCellSize(config) * 1.08;
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
    final baseFontSize = minStep * 0.4;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final baseCenter = Offset((column + 0.5) * stepX, (row + 0.5) * stepY);
        final nx = column / math.max(1, columns - 1);
        final ny = row / math.max(1, rows - 1);
        final noise = seededValue(config.randomSeed, column, row);
        final ambientOffset = resolveAmbientOffset(
          seed: config.randomSeed,
          x: column,
          y: row,
          z: 5,
          time: time,
          amplitudeX: stepX * config.randomMotionStrength * 0.24,
          amplitudeY: stepY * config.randomMotionStrength * 0.22,
        );
        final wave = math.sin((nx * 8.5) + (time * 1.35) + noise * 2.4) +
            math.cos((ny * 7.2) - (time * 1.1) + noise * 1.6);
        final baseOffset = Offset(
          math.cos((ny * 8.0) + (time * 1.05) + noise * 1.8) * stepX * 0.08,
          wave * stepY * 0.11,
        );
        final center = baseCenter + ambientOffset;
        final pointerInfluence = frame.radialInfluence(
          center,
          radius: config.interactionRadius * 1.12,
          easing: config.easing,
        );
        final pointer = frame.pointerPosition;
        final distance = pointer == null ? 0.0 : (center - pointer).distance;
        final disturbance = pointer == null
            ? 0.0
            : math.sin(distance * 0.08 - time * 5.2) *
                pointerInfluence *
                stepY *
                0.38;
        final ripple = sampleRippleDisturbance(
          center: center,
          ripples: frame.ripples,
          time: time,
          minStep: minStep,
          config: config,
          displacementScale: 0.42,
          bandWidthScale: 1.15,
        );
        final influence = math.max(pointerInfluence, ripple.influence);

        final animatedCenter =
            center + baseOffset.translate(0, disturbance) + ripple.offset;
        final shimmer = sine01(time * 1.2 + noise * math.pi * 2);
        final idleScale =
            lerpScalar(config.minScale, 1.0, 0.58 + shimmer * 0.42);
        final fontSize = baseFontSize *
            lerpScalar(0.92, 1.2, shimmer) *
            lerpScalar(idleScale, config.maxScale * 0.78, influence);
        final baseColor = samplePaletteColor(animatedCenter, anchors);
        final color = mixColors(
          multiplyAlpha(baseColor, 0.5 + shimmer * 0.24),
          accent,
          (influence * 0.34) + (shimmer * 0.08),
        );

        if (shimmer > 0.58 || influence > 0.12) {
          context.paintMark(
            canvas,
            symbol: config.symbol,
            shape: config.shape,
            center: animatedCenter.translate(stepX * 0.05, 0),
            fontSize: fontSize * 1.22,
            color: multiplyAlpha(accent, 0.05 + influence * 0.12),
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
          fontWeight: FontWeight.w600,
        );
      }
    }
  }
}
