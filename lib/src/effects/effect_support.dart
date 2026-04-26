import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';
import '../models/visual_effect_frame.dart';

/// Resolves a practical grid spacing from the shared [config].
double resolveCellSize(VisualEffectConfig config) {
  final density = config.density.clamp(0.35, 3.5);
  return (config.baseCellSize / density).clamp(10.0, 96.0);
}

/// Returns the shared palette used by built-in effects.
///
/// When [VisualEffectConfig.effectColors] is empty, the palette falls back to
/// the configured foreground and accent colors.
List<Color> resolveEffectPalette(VisualEffectConfig config) {
  final basePalette = config.effectColors.isNotEmpty
      ? config.effectColors
      : <Color>[
          config.foregroundColor,
          mixColors(config.foregroundColor, config.accentColor, 0.42),
          config.accentColor,
        ];

  return <Color>[
    for (final color in basePalette.take(5))
      applyOpacity(color, config.opacity),
  ];
}

/// Builds drifting palette anchors used to sample gradient-like color fields.
List<EffectPaletteAnchor> buildPaletteAnchors({
  required Size size,
  required List<Color> palette,
  required double time,
  required double motionStrength,
}) {
  final positions = switch (palette.length) {
    0 => const <Offset>[],
    1 => <Offset>[Offset(size.width * 0.5, size.height * 0.5)],
    2 => <Offset>[
        Offset(size.width * 0.22, size.height * 0.5),
        Offset(size.width * 0.78, size.height * 0.5),
      ],
    3 => <Offset>[
        Offset(size.width * 0.24, size.height * 0.2),
        Offset(size.width * 0.78, size.height * 0.24),
        Offset(size.width * 0.5, size.height * 0.78),
      ],
    4 => <Offset>[
        Offset(size.width * 0.18, size.height * 0.18),
        Offset(size.width * 0.82, size.height * 0.22),
        Offset(size.width * 0.2, size.height * 0.82),
        Offset(size.width * 0.8, size.height * 0.78),
      ],
    _ => <Offset>[
        Offset(size.width * 0.16, size.height * 0.18),
        Offset(size.width * 0.84, size.height * 0.22),
        Offset(size.width * 0.2, size.height * 0.82),
        Offset(size.width * 0.82, size.height * 0.78),
        Offset(size.width * 0.5, size.height * 0.5),
      ],
  };

  return List<EffectPaletteAnchor>.generate(palette.length, (index) {
    final base = positions[index];
    final driftScale = motionStrength * 0.045;
    final drift = Offset(
      math.sin(time * 0.28 + index * 1.17) * size.width * driftScale,
      math.cos(time * 0.24 + index * 1.43) * size.height * driftScale,
    );
    return EffectPaletteAnchor(base + drift, palette[index]);
  });
}

/// Samples a blended color from [anchors] at [position].
Color samplePaletteColor(Offset position, List<EffectPaletteAnchor> anchors) {
  if (anchors.isEmpty) {
    return const Color(0xFFFFFFFF);
  }
  if (anchors.length == 1) {
    return anchors.first.color;
  }

  var totalWeight = 0.0;
  var red = 0.0;
  var green = 0.0;
  var blue = 0.0;
  var alpha = 0.0;

  for (final anchor in anchors) {
    final distance = (position - anchor.position).distance;
    final weight = 1 / math.max(52.0, distance);
    totalWeight += weight;
    red += anchor.color.r * weight;
    green += anchor.color.g * weight;
    blue += anchor.color.b * weight;
    alpha += anchor.color.a * weight;
  }

  return Color.fromARGB(
    ((alpha / totalWeight) * 255).round() & 0xff,
    ((red / totalWeight) * 255).round() & 0xff,
    ((green / totalWeight) * 255).round() & 0xff,
    ((blue / totalWeight) * 255).round() & 0xff,
  );
}

/// Returns a deterministic idle offset used to add ambient motion.
Offset resolveAmbientOffset({
  required int seed,
  required int x,
  required int y,
  required double time,
  required double amplitudeX,
  required double amplitudeY,
  int z = 0,
}) {
  if (amplitudeX <= 0 && amplitudeY <= 0) {
    return Offset.zero;
  }

  final phase = seededValue(seed, x, y, z) * math.pi * 2;
  final speedX = 0.55 + seededValue(seed, x, y, z + 1) * 0.9;
  final speedY = 0.6 + seededValue(seed, x, y, z + 2) * 1.0;
  return Offset(
    math.sin(time * speedX + phase) * amplitudeX,
    math.cos(time * speedY - phase * 0.8) * amplitudeY,
  );
}

/// Samples click or touch ripple disturbance for [center].
EffectDisturbanceSample sampleRippleDisturbance({
  required Offset center,
  required List<VisualEffectRipple> ripples,
  required double time,
  required double minStep,
  required VisualEffectConfig config,
  double displacementScale = 0.85,
  double radiusScale = 1.0,
  double bandWidthScale = 1.0,
}) {
  if (ripples.isEmpty) {
    return const EffectDisturbanceSample(Offset.zero, 0);
  }

  var offset = Offset.zero;
  var influence = 0.0;

  for (final ripple in ripples) {
    final direction = center - ripple.position;
    final distance = direction.distance;
    if (distance <= 0) {
      continue;
    }

    final radius = ripple.ageSeconds *
        minStep *
        (3.2 + config.animationSpeed * 2.2) *
        radiusScale;
    final bandWidth = minStep * (0.9 + config.maxScale * 0.2) * bandWidthScale;
    final band = (distance - radius).abs() / bandWidth;
    if (band >= 2.8) {
      continue;
    }

    final envelope = math.exp(-band * band * 0.9) * ripple.strength;
    final oscillation = math.sin(band * math.pi - time * 0.6);
    offset += (direction / distance) *
        oscillation *
        envelope *
        minStep *
        displacementScale;
    influence = math.max(influence, envelope);
  }

  return EffectDisturbanceSample(offset, influence);
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

/// Scales the alpha component of [color] by [factor].
Color multiplyAlpha(Color color, double factor) {
  final alpha = ((color.a * factor.clamp(0.0, 1.0)) * 255.0).round() & 0xff;
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

/// Anchor point used when sampling an effect palette.
@immutable
class EffectPaletteAnchor {
  /// Creates a palette anchor.
  const EffectPaletteAnchor(this.position, this.color);

  /// Anchor position inside the effect's local coordinate space.
  final Offset position;

  /// Anchor color contribution.
  final Color color;
}

/// Shared disturbance sample used by ripple-aware effects.
@immutable
class EffectDisturbanceSample {
  /// Creates a disturbance sample.
  const EffectDisturbanceSample(this.offset, this.influence);

  /// Offset contribution for the sampled cell.
  final Offset offset;

  /// Influence value in the `0..1` range.
  final double influence;
}
