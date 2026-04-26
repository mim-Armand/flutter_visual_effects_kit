import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';

/// Shared drawing helpers available to visual effects during painting.
///
/// The context is intentionally small in v1, but it already exposes a cached
/// symbol painter plus lightweight shape rendering for procedural effects.
class VisualEffectDrawingContext {
  /// Creates a drawing context with lightweight internal caches.
  VisualEffectDrawingContext();

  final _SymbolPainterCache _symbolPainterCache = _SymbolPainterCache();
  final _ShapePainter _shapePainter = _ShapePainter();

  /// Paints either [symbol] or [shape] centered on [center].
  ///
  /// When [shape] is [VisualEffectShape.none], the text [symbol] is used.
  void paintMark(
    Canvas canvas, {
    required String symbol,
    required VisualEffectShape shape,
    required Offset center,
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    if (shape == VisualEffectShape.none) {
      paintSymbol(
        canvas,
        symbol: symbol,
        center: center,
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      );
      return;
    }

    _shapePainter.paint(
      canvas,
      shape: shape,
      center: center,
      size: fontSize,
      color: color,
    );
  }

  /// Paints a text symbol centered on [center] using an internal cache.
  void paintSymbol(
    Canvas canvas, {
    required String symbol,
    required Offset center,
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    _symbolPainterCache.paint(
      canvas,
      symbol: symbol,
      center: center,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}

class _SymbolPainterCache {
  final Map<_SymbolPainterKey, TextPainter> _cache =
      <_SymbolPainterKey, TextPainter>{};

  void paint(
    Canvas canvas, {
    required String symbol,
    required Offset center,
    required double fontSize,
    required Color color,
    required FontWeight fontWeight,
  }) {
    if (symbol.isEmpty || fontSize <= 0) {
      return;
    }

    final quantizedSize = (fontSize * 4).round() / 4;
    final quantizedColor = _quantizeColor(color);
    final key = _SymbolPainterKey(
      symbol: symbol,
      fontSize: quantizedSize,
      color: quantizedColor,
      fontWeight: fontWeight,
    );

    if (_cache.length > 320) {
      _cache.clear();
    }

    final painter = _cache.putIfAbsent(key, () {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            color: quantizedColor,
            fontSize: quantizedSize,
            height: 1,
            fontWeight: fontWeight,
            letterSpacing: symbol.length == 1 ? -quantizedSize * 0.06 : 0,
          ),
        ),
      )..layout();
      return textPainter;
    });

    final offset = Offset(
      center.dx - painter.width / 2,
      center.dy - painter.height / 2,
    );
    painter.paint(canvas, offset);
  }

  Color _quantizeColor(Color color) {
    int quantizeChannel(double channel) {
      final value = (channel * 255).round().clamp(0, 255);
      const step = 17;
      return (((value / step).round()) * step).clamp(0, 255);
    }

    return Color.fromARGB(
      quantizeChannel(color.a),
      quantizeChannel(color.r),
      quantizeChannel(color.g),
      quantizeChannel(color.b),
    );
  }
}

class _ShapePainter {
  final Map<_ShapePathKey, Path> _starCache = <_ShapePathKey, Path>{};

  void paint(
    Canvas canvas, {
    required VisualEffectShape shape,
    required Offset center,
    required double size,
    required Color color,
  }) {
    if (size <= 0) {
      return;
    }

    final quantizedSize = (size * 4).round() / 4;
    final paint = Paint()
      ..isAntiAlias = true
      ..color = color;

    switch (shape) {
      case VisualEffectShape.none:
        return;
      case VisualEffectShape.circle:
        canvas.drawCircle(center, quantizedSize * 0.28, paint);
        return;
      case VisualEffectShape.square:
        final extent = quantizedSize * 0.56;
        final rect = Rect.fromCenter(
          center: center,
          width: extent,
          height: extent,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(extent * 0.16)),
          paint,
        );
        return;
      case VisualEffectShape.star:
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.drawPath(_starPathFor(quantizedSize), paint);
        canvas.restore();
        return;
    }
  }

  Path _starPathFor(double size) {
    final key = _ShapePathKey(VisualEffectShape.star, size);
    if (_starCache.length > 120) {
      _starCache.clear();
    }
    return _starCache.putIfAbsent(key, () {
      final outerRadius = size * 0.34;
      final innerRadius = outerRadius * 0.46;
      final path = Path();

      for (var index = 0; index < 10; index++) {
        final radius = index.isEven ? outerRadius : innerRadius;
        final angle = (-math.pi / 2) + (math.pi / 5) * index;
        final point = Offset(
          math.cos(angle) * radius,
          math.sin(angle) * radius,
        );
        if (index == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      path.close();
      return path;
    });
  }
}

@immutable
class _SymbolPainterKey {
  const _SymbolPainterKey({
    required this.symbol,
    required this.fontSize,
    required this.color,
    required this.fontWeight,
  });

  final String symbol;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _SymbolPainterKey &&
        other.symbol == symbol &&
        other.fontSize == fontSize &&
        other.color == color &&
        other.fontWeight == fontWeight;
  }

  @override
  int get hashCode => Object.hash(symbol, fontSize, color, fontWeight);
}

@immutable
class _ShapePathKey {
  const _ShapePathKey(this.shape, this.size);

  final VisualEffectShape shape;
  final double size;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _ShapePathKey && other.shape == shape && other.size == size;
  }

  @override
  int get hashCode => Object.hash(shape, size);
}
