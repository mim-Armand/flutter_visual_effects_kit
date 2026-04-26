import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';
import '../models/visual_effect_frame.dart';
import '../rendering/visual_effect_drawing_context.dart';
import 'effect_support.dart';
import 'visual_effect.dart';

/// A liquid field that responds to hover motion and click or touch ripples.
class LiquidRippleEffect extends VisualEffect {
  /// Creates the liquid ripple effect.
  const LiquidRippleEffect();

  @override
  String get name => 'liquidRipple';

  @override
  String get displayName => 'Liquid Ripple';

  @override
  String get description =>
      'A liquid field stirred by the pointer with ripples triggered by taps and clicks.';

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

    final time = frame.timeSeconds * (0.9 + config.animationSpeed * 0.85);
    final palette = resolveEffectPalette(config);
    final anchors = buildPaletteAnchors(
      size: size,
      palette: palette,
      time: time,
      motionStrength: config.randomMotionStrength,
    );

    final cellSize = resolveCellSize(config) * 1.18;
    final columns = math.max(1, (size.width / cellSize).round());
    final rows = math.max(1, (size.height / cellSize).round());
    final stepX = size.width / columns;
    final stepY = size.height / rows;
    final minStep = math.min(stepX, stepY);
    final fillPaint = Paint()..isAntiAlias = true;
    final glowPaint = Paint()..isAntiAlias = true;
    final ripplePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    final baseFontSize = minStep * 0.34;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final baseCenter = Offset((column + 0.5) * stepX, (row + 0.5) * stepY);
        final noise = seededValue(config.randomSeed, column, row);
        final offset = _baseLiquidOffset(
          baseCenter: baseCenter,
          size: size,
          time: time,
          minStep: minStep,
          noise: noise,
          randomMotionStrength: config.randomMotionStrength,
        );

        final pointerResponse = _pointerResponse(
          baseCenter,
          frame,
          time,
          minStep,
          config,
        );
        final rippleResponse = sampleRippleDisturbance(
          center: baseCenter,
          ripples: frame.ripples,
          time: time,
          minStep: minStep,
          config: config,
        );

        final center = baseCenter +
            offset +
            pointerResponse.offset +
            rippleResponse.offset;
        final color = samplePaletteColor(center, anchors);
        final pulse = sine01(
          time * 1.45 + noise * math.pi * 2 + row * 0.16 + column * 0.11,
        );
        final influence = math.max(
          pointerResponse.influence,
          rippleResponse.influence,
        );

        final fontSize = baseFontSize *
            (0.92 + noise * 0.32) *
            lerpScalar(0.92, 1.16, pulse) *
            lerpScalar(config.minScale, config.maxScale * 0.72, influence);
        final glowFontSize = fontSize * lerpScalar(1.7, 2.35, influence);

        glowPaint.color = multiplyAlpha(
          color,
          0.06 + pulse * 0.04 + influence * 0.12,
        );
        fillPaint.color = multiplyAlpha(
          color,
          0.68 + pulse * 0.2 + influence * 0.08,
        );

        if (glowPaint.color.a > 0.001) {
          context.paintMark(
            canvas,
            symbol: config.symbol,
            shape: config.shape,
            center: center,
            fontSize: glowFontSize,
            color: glowPaint.color,
            fontWeight: FontWeight.w500,
          );
        }
        context.paintMark(
          canvas,
          symbol: config.symbol,
          shape: config.shape,
          center: center,
          fontSize: fontSize,
          color: fillPaint.color,
          fontWeight: FontWeight.w600,
        );
      }
    }

    for (final ripple in frame.ripples) {
      final color = samplePaletteColor(ripple.position, anchors);
      final radius =
          ripple.ageSeconds * minStep * (3.2 + config.animationSpeed * 2.2);
      ripplePaint
        ..color = multiplyAlpha(color, ripple.strength * 0.52)
        ..strokeWidth =
            minStep * lerpScalar(0.05, 0.14, ripple.strength.clamp(0.0, 1.0));
      canvas.drawCircle(ripple.position, radius, ripplePaint);
    }
  }

  Offset _baseLiquidOffset({
    required Offset baseCenter,
    required Size size,
    required double time,
    required double minStep,
    required double noise,
    required double randomMotionStrength,
  }) {
    final nx = baseCenter.dx / math.max(1.0, size.width);
    final ny = baseCenter.dy / math.max(1.0, size.height);
    final waveX = math.sin(nx * 9.2 + time * 1.2 + noise * 2.6) +
        math.cos(ny * 7.6 - time * 0.95 + noise * 1.4);
    final waveY = math.cos(nx * 7.1 - time * 1.08 + noise * 1.7) +
        math.sin(ny * 8.4 + time * 0.86 + noise * 2.2);
    final strength = minStep * randomMotionStrength * 0.78;
    return Offset(waveX * strength, waveY * strength);
  }

  _DisplacementSample _pointerResponse(
    Offset center,
    VisualEffectFrame frame,
    double time,
    double minStep,
    VisualEffectConfig config,
  ) {
    final pointer = frame.pointerPosition;
    if (pointer == null) {
      return const _DisplacementSample(Offset.zero, 0);
    }

    final toCenter = center - pointer;
    final distance = toCenter.distance;
    if (distance <= 0) {
      return const _DisplacementSample(Offset.zero, 0);
    }

    final influence = frame.radialInfluence(
      center,
      radius: config.interactionRadius * 1.18,
      easing: config.easing,
    );
    if (influence <= 0) {
      return const _DisplacementSample(Offset.zero, 0);
    }

    final normal = toCenter / distance;
    final tangent = Offset(-normal.dy, normal.dx);
    final swirl = math.sin(distance * 0.08 - time * 4.8);
    final offset = tangent * swirl * influence * minStep * 0.72 +
        normal * influence * minStep * (0.12 + swirl * 0.22);
    return _DisplacementSample(offset, influence);
  }
}

class _DisplacementSample {
  const _DisplacementSample(this.offset, this.influence);

  final Offset offset;
  final double influence;
}
