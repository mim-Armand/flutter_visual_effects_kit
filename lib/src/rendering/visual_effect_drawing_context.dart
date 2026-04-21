import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Shared drawing helpers available to visual effects during painting.
///
/// The context is intentionally small in v1, but it already exposes a cached
/// symbol painter for text-based procedural effects such as `plusGrid`.
class VisualEffectDrawingContext {
  /// Creates a drawing context with lightweight internal caches.
  VisualEffectDrawingContext();

  final _SymbolPainterCache _symbolPainterCache = _SymbolPainterCache();

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
    final key = _SymbolPainterKey(
      symbol: symbol,
      fontSize: quantizedSize,
      color: color,
      fontWeight: fontWeight,
    );

    if (_cache.length > 240) {
      _cache.clear();
    }

    final painter = _cache.putIfAbsent(key, () {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            color: color,
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
