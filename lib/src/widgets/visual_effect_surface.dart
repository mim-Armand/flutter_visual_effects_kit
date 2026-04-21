import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../effects/effect_support.dart';
import '../effects/visual_effect.dart';
import '../effects/visual_effect_registry.dart';
import '../models/visual_effect_config.dart';
import '../models/visual_effect_frame.dart';
import '../rendering/visual_effect_drawing_context.dart';

/// Paints a procedural visual effect behind an optional child.
class VisualEffectSurface extends StatefulWidget {
  /// Creates a visual effect surface.
  const VisualEffectSurface({
    super.key,
    this.effectName,
    this.effectIndex,
    this.config = const VisualEffectConfig(),
    this.child,
    this.fit = BoxFit.cover,
    this.interactive = true,
    this.repaintContinuously = true,
  });

  /// Name of the effect to use. This takes precedence over [effectIndex].
  final String? effectName;

  /// Index of the effect to use when [effectName] is not provided.
  final int? effectIndex;

  /// Shared configuration passed into the selected effect.
  final VisualEffectConfig config;

  /// Optional content painted above the effect.
  final Widget? child;

  /// Fit applied to the effect's procedural coordinate space.
  final BoxFit fit;

  /// Enables pointer tracking when supported by the platform.
  final bool interactive;

  /// Repaints continuously for animated idle motion.
  ///
  /// When disabled, built-in idle animation pauses once pointer interaction
  /// settles.
  final bool repaintContinuously;

  @override
  State<VisualEffectSurface> createState() => _VisualEffectSurfaceState();
}

class _VisualEffectSurfaceState extends State<VisualEffectSurface>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final _SurfaceFrameState _frameState;
  late final VisualEffectDrawingContext _drawingContext;

  @override
  void initState() {
    super.initState();
    _frameState = _SurfaceFrameState();
    _drawingContext = VisualEffectDrawingContext();
    _ticker = createTicker(_handleTick);
    _syncTicker();
  }

  bool get _pointerEnabled =>
      widget.interactive && widget.config.enablePointerInteraction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ticker.muted = !TickerMode.of(context);
  }

  @override
  void didUpdateWidget(covariant VisualEffectSurface oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_pointerEnabled) {
      _frameState.clearPointer(immediate: true);
    } else if (!oldWidget.interactive && widget.interactive) {
      _frameState.markNeedsPaint();
    }

    if (oldWidget.repaintContinuously != widget.repaintContinuously) {
      _syncTicker();
    } else {
      _ensureTickerRunning();
    }
  }

  void _handleTick(Duration elapsed) {
    final keepRunning = _frameState.advance(elapsed);
    if (!widget.repaintContinuously && !keepRunning) {
      _ticker.stop();
      _frameState.resetTickAnchor();
    }
  }

  void _syncTicker() {
    if (widget.repaintContinuously) {
      _ensureTickerRunning();
    } else if (!_frameState.isAnimating) {
      _ticker.stop();
      _frameState.resetTickAnchor();
    } else {
      _ensureTickerRunning();
    }
  }

  void _ensureTickerRunning() {
    if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _updatePointer(Offset localPosition) {
    if (!_pointerEnabled) {
      return;
    }
    _frameState.setPointer(localPosition);
    _ensureTickerRunning();
  }

  void _clearPointer() {
    if (!_pointerEnabled) {
      return;
    }
    _frameState.clearPointer();
    if (!widget.repaintContinuously) {
      _ensureTickerRunning();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effect = VisualEffects.resolve(
      effectName: widget.effectName,
      effectIndex: widget.effectIndex,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = Size(
          _resolveDimension(constraints.maxWidth, constraints.minWidth),
          _resolveDimension(constraints.maxHeight, constraints.minHeight),
        );

        Widget content = RepaintBoundary(
          child: CustomPaint(
            isComplex: true,
            willChange: widget.repaintContinuously || _pointerEnabled,
            painter: _VisualEffectPainter(
              effect: effect,
              config: widget.config,
              fit: widget.fit,
              frameState: _frameState,
              drawingContext: _drawingContext,
            ),
            child: SizedBox.fromSize(
              size: size,
              child: widget.child == null
                  ? const SizedBox.expand()
                  : Align(alignment: Alignment.center, child: widget.child),
            ),
          ),
        );

        if (_pointerEnabled) {
          content = MouseRegion(
            opaque: false,
            cursor: SystemMouseCursors.basic,
            onHover: (event) => _updatePointer(event.localPosition),
            onExit: (_) => _clearPointer(),
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) => _updatePointer(event.localPosition),
              onPointerMove: (event) => _updatePointer(event.localPosition),
              onPointerHover: (event) => _updatePointer(event.localPosition),
              onPointerUp: (_) => _clearPointer(),
              onPointerCancel: (_) => _clearPointer(),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }

  static double _resolveDimension(double max, double min) {
    if (max.isFinite) {
      return max;
    }
    if (min.isFinite) {
      return min;
    }
    return 0;
  }
}

class _VisualEffectPainter extends CustomPainter {
  _VisualEffectPainter({
    required this.effect,
    required this.config,
    required this.fit,
    required this.frameState,
    required this.drawingContext,
  }) : super(repaint: frameState);

  final VisualEffect effect;
  final VisualEffectConfig config;
  final BoxFit fit;
  final _SurfaceFrameState frameState;
  final VisualEffectDrawingContext drawingContext;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundColor = applyOpacity(
      config.backgroundColor,
      config.opacity,
    );
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    if (size.isEmpty) {
      return;
    }

    final paddedRect = _resolvePaddedRect(size, config.padding);
    final paintRect = resolveFitRect(paddedRect, fit);
    if (paintRect.isEmpty) {
      return;
    }

    final pointer = frameState.pointerPosition;
    final localPointer = pointer?.translate(-paintRect.left, -paintRect.top);

    final frame = VisualEffectFrame(
      canvasSize: size,
      paintRect: paintRect,
      fit: fit,
      timeSeconds: frameState.elapsedSeconds,
      pointerPosition: localPointer,
      pointerStrength: frameState.pointerStrength,
    );

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(paintRect.left, paintRect.top);
    effect.paint(canvas, config, frame, drawingContext);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VisualEffectPainter oldDelegate) {
    return oldDelegate.effect.name != effect.name ||
        oldDelegate.config != config ||
        oldDelegate.fit != fit;
  }

  Rect _resolvePaddedRect(Size size, EdgeInsets padding) {
    final left = math.min(padding.left, size.width);
    final top = math.min(padding.top, size.height);
    final right = math.min(padding.right, math.max(0.0, size.width - left));
    final bottom = math.min(padding.bottom, math.max(0.0, size.height - top));
    return Rect.fromLTWH(
      left,
      top,
      math.max(0.0, size.width - left - right),
      math.max(0.0, size.height - top - bottom),
    );
  }
}

class _SurfaceFrameState extends ChangeNotifier {
  Duration? _lastElapsed;
  double _elapsedSeconds = 0;
  Offset? _currentPointer;
  Offset? _targetPointer;
  double _pointerStrength = 0;
  double _targetPointerStrength = 0;

  double get elapsedSeconds => _elapsedSeconds;
  Offset? get pointerPosition => _currentPointer;
  double get pointerStrength => _pointerStrength;

  bool get isAnimating =>
      _targetPointer != null ||
      _targetPointerStrength > 0 ||
      _pointerStrength > 0.001;

  void setPointer(Offset localPosition) {
    _targetPointer = localPosition;
    _currentPointer ??= localPosition;
    _pointerStrength = math.max(_pointerStrength, 0.45);
    _targetPointerStrength = 1;
    notifyListeners();
  }

  void clearPointer({bool immediate = false}) {
    _targetPointer = null;
    _targetPointerStrength = 0;

    if (immediate) {
      _currentPointer = null;
      _pointerStrength = 0;
      notifyListeners();
    }
  }

  void markNeedsPaint() => notifyListeners();

  void resetTickAnchor() {
    _lastElapsed = null;
  }

  bool advance(Duration elapsed) {
    double deltaSeconds = 0;
    final lastElapsed = _lastElapsed;
    if (lastElapsed != null && elapsed >= lastElapsed) {
      deltaSeconds = (elapsed - lastElapsed).inMicroseconds /
          Duration.microsecondsPerSecond;
      if (deltaSeconds > 0.25) {
        deltaSeconds = 1 / 60;
      }
    }
    _lastElapsed = elapsed;
    _elapsedSeconds += deltaSeconds;

    final interactionLerp = 1 - math.exp(-deltaSeconds * 9);
    final pointerLerp = 1 - math.exp(-deltaSeconds * 14);

    if (_targetPointer != null) {
      _currentPointer = Offset.lerp(
        _currentPointer ?? _targetPointer,
        _targetPointer,
        pointerLerp.clamp(0.0, 1.0),
      );
    } else if (_pointerStrength <= 0.001) {
      _currentPointer = null;
    }

    _pointerStrength = _lerp(
      _pointerStrength,
      _targetPointerStrength,
      interactionLerp.clamp(0.0, 1.0),
    );

    if ((_pointerStrength - _targetPointerStrength).abs() < 0.001) {
      _pointerStrength = _targetPointerStrength;
    }

    if (_targetPointer == null && _pointerStrength <= 0.001) {
      _currentPointer = null;
      _pointerStrength = 0;
    }

    notifyListeners();
    return isAnimating;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
