import 'package:flutter/painting.dart';

import '../models/visual_effect_config.dart';
import '../models/visual_effect_frame.dart';
import '../rendering/visual_effect_drawing_context.dart';

/// Base contract for a procedural visual effect.
abstract class VisualEffect {
  /// Creates a visual effect definition.
  const VisualEffect();

  /// Stable programmatic identifier used by the registry.
  String get name;

  /// User-facing label suitable for demos and control panels.
  String get displayName;

  /// Short description of the effect.
  String get description;

  /// Paints the current frame into [canvas].
  ///
  /// The canvas is translated into the local fitted effect rect before this
  /// method is called.
  void paint(
    Canvas canvas,
    VisualEffectConfig config,
    VisualEffectFrame frame,
    VisualEffectDrawingContext context,
  );
}
