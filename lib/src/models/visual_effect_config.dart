import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Immutable configuration shared by built-in and custom visual effects.
///
/// The defaults are tuned for modern backgrounds on desktop and web while
/// remaining lightweight enough for mobile use.
@immutable
class VisualEffectConfig {
  /// Creates a new effect configuration.
  const VisualEffectConfig({
    this.backgroundColor = const Color(0xFF08111E),
    this.foregroundColor = const Color(0xFFD8E7FF),
    this.accentColor = const Color(0xFF70F4E1),
    this.effectColors = const <Color>[],
    this.density = 1.0,
    this.symbol = '+',
    this.shape = VisualEffectShape.none,
    this.baseCellSize = 28.0,
    this.minScale = 0.9,
    this.maxScale = 2.4,
    this.interactionRadius = 140.0,
    this.animationSpeed = 1.0,
    this.randomMotionStrength = 0.18,
    this.easing = Curves.easeOutCubic,
    this.enablePointerInteraction = true,
    this.enableRipples = true,
    this.opacity = 1.0,
    this.padding = EdgeInsets.zero,
    this.randomSeed = 7,
  })  : assert(density > 0, 'density must be greater than zero'),
        assert(baseCellSize > 0, 'baseCellSize must be greater than zero'),
        assert(minScale > 0, 'minScale must be greater than zero'),
        assert(maxScale >= minScale, 'maxScale must be >= minScale'),
        assert(
          interactionRadius > 0,
          'interactionRadius must be greater than zero',
        ),
        assert(
          animationSpeed >= 0,
          'animationSpeed must be greater than or equal to zero',
        ),
        assert(
          randomMotionStrength >= 0,
          'randomMotionStrength must be greater than or equal to zero',
        ),
        assert(opacity >= 0 && opacity <= 1, 'opacity must be between 0 and 1'),
        assert(symbol != '', 'symbol must not be empty');

  /// Background color painted behind the procedural effect.
  final Color backgroundColor;

  /// Primary color used for the base marks, dots, or grid elements.
  final Color foregroundColor;

  /// Secondary highlight color used around interaction or animated peaks.
  final Color accentColor;

  /// Optional palette used by effects that support multi-point color blending.
  ///
  /// Up to five colors are used. Any additional colors are ignored.
  final List<Color> effectColors;

  /// Multiplier controlling how densely the effect fills its surface.
  ///
  /// Higher values create more cells and finer detail.
  final double density;

  /// Symbol drawn by text-based effects such as plus-grid layouts.
  final String symbol;

  /// Optional built-in shape drawn instead of [symbol].
  final VisualEffectShape shape;

  /// Base spacing seed used to derive the grid or field cadence.
  final double baseCellSize;

  /// Minimum resting scale used by animated elements.
  final double minScale;

  /// Maximum emphasized scale used near the pointer or other disturbances.
  final double maxScale;

  /// Radius around the active pointer position that receives interaction.
  final double interactionRadius;

  /// Global animation speed multiplier.
  final double animationSpeed;

  /// Controls the strength of seeded idle motion in effects that support it.
  final double randomMotionStrength;

  /// Easing curve applied to interaction falloff.
  final Curve easing;

  /// Enables pointer interaction when the surface itself is interactive.
  final bool enablePointerInteraction;

  /// Enables click or touch ripples for effects that react to them.
  final bool enableRipples;

  /// Opacity applied to the background and effect strokes together.
  final double opacity;

  /// Insets applied before the effect is fitted into the widget bounds.
  final EdgeInsets padding;

  /// Deterministic seed used for subtle per-cell variation.
  final int randomSeed;

  /// Returns a copy with any provided fields replaced.
  VisualEffectConfig copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? accentColor,
    List<Color>? effectColors,
    double? density,
    String? symbol,
    VisualEffectShape? shape,
    double? baseCellSize,
    double? minScale,
    double? maxScale,
    double? interactionRadius,
    double? animationSpeed,
    double? randomMotionStrength,
    Curve? easing,
    bool? enablePointerInteraction,
    bool? enableRipples,
    double? opacity,
    EdgeInsets? padding,
    int? randomSeed,
  }) {
    return VisualEffectConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      accentColor: accentColor ?? this.accentColor,
      effectColors: effectColors ?? this.effectColors,
      density: density ?? this.density,
      symbol: symbol ?? this.symbol,
      shape: shape ?? this.shape,
      baseCellSize: baseCellSize ?? this.baseCellSize,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      interactionRadius: interactionRadius ?? this.interactionRadius,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      randomMotionStrength: randomMotionStrength ?? this.randomMotionStrength,
      easing: easing ?? this.easing,
      enablePointerInteraction:
          enablePointerInteraction ?? this.enablePointerInteraction,
      enableRipples: enableRipples ?? this.enableRipples,
      opacity: opacity ?? this.opacity,
      padding: padding ?? this.padding,
      randomSeed: randomSeed ?? this.randomSeed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is VisualEffectConfig &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.accentColor == accentColor &&
        listEquals(other.effectColors, effectColors) &&
        other.density == density &&
        other.symbol == symbol &&
        other.shape == shape &&
        other.baseCellSize == baseCellSize &&
        other.minScale == minScale &&
        other.maxScale == maxScale &&
        other.interactionRadius == interactionRadius &&
        other.animationSpeed == animationSpeed &&
        other.randomMotionStrength == randomMotionStrength &&
        other.easing == easing &&
        other.enablePointerInteraction == enablePointerInteraction &&
        other.enableRipples == enableRipples &&
        other.opacity == opacity &&
        other.padding == padding &&
        other.randomSeed == randomSeed;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        accentColor,
        Object.hashAll(effectColors),
        density,
        symbol,
        shape,
        baseCellSize,
        minScale,
        maxScale,
        interactionRadius,
        animationSpeed,
        randomMotionStrength,
        easing,
        enablePointerInteraction,
        enableRipples,
        opacity,
        padding,
        randomSeed,
      );
}

/// Built-in vector shapes that can be used instead of a text symbol.
enum VisualEffectShape {
  /// Uses [VisualEffectConfig.symbol].
  none,

  /// Draws a circle at each effect point.
  circle,

  /// Draws a square at each effect point.
  square,

  /// Draws a five-point star at each effect point.
  star,
}
