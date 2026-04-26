# visual_effects_kit

`visual_effects_kit` is a publishable Flutter package for procedural, animated visual effects that fill any rectangular widget, clipped surface, or background layer with smooth motion and optional pointer interaction.

It is designed for modern Flutter UIs on web, desktop, and mobile, with a clean registry-driven architecture that lets you select effects by `effectName` or `effectIndex` and register your own effects later.

## Features

- Reusable `VisualEffectSurface` widget for backgrounds and shaped surfaces
- Built-in effect registry with lookup by string name or integer index
- Four included effects: `plusGrid`, `dotField`, `waveGrid`, and `liquidRipple`
- Shared symbol, shape, palette, random motion, and ripple controls across all built-in effects
- Premium hover response on web and desktop, with touch-friendly fallback on mobile
- Strongly typed immutable `VisualEffectConfig` with `copyWith`
- Clean custom effect API for future package or app-specific extensions
- Lightweight v1 implementation using only Flutter primitives

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  visual_effects_kit: ^0.1.4
```

Then fetch packages:

```bash
flutter pub get
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:visual_effects_kit/visual_effects_kit.dart';

class HeroBackground extends StatelessWidget {
  const HeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return VisualEffectSurface(
      effectName: 'plusGrid',
      config: const VisualEffectConfig(
        backgroundColor: Color(0xFF08111E),
        foregroundColor: Color(0xFFD8E7FF),
        accentColor: Color(0xFF7AF3E0),
        density: 1.2,
        maxScale: 2.4,
        interactionRadius: 150,
      ),
      child: const Center(
        child: Text(
          'Interactive Background',
          style: TextStyle(color: Colors.white, fontSize: 28),
        ),
      ),
    );
  }
}
```

## Selecting effects

Use either the effect name or effect index:

```dart
VisualEffectSurface(effectName: 'dotField');
VisualEffectSurface(effectIndex: 2);
```

Resolution rules:

- If `effectName` is provided, it wins
- Otherwise `effectIndex` is used
- Otherwise the first registered effect is used

Registry helpers:

```dart
final names = VisualEffects.effectNames;
final count = VisualEffects.effectCount;
final effects = VisualEffects.availableEffects;
```

## Built-in effects

- `plusGrid`: A responsive grid of text glyphs or shapes that smoothly scales near the pointer
- `dotField`: A softly animated field of glyphs or shapes with hover-reactive emphasis and ripple-aware highlights
- `waveGrid`: A subtle grid of glyphs or shapes with wave motion, palette blending, and optional pointer disturbance
- `liquidRipple`: A liquid field of drifting glyphs or shapes with click or touch ripples, pointer stirring, and support for up to five blended colors

## Configuration

`VisualEffectConfig` keeps the public API small and practical while still covering the most useful controls:

```dart
const config = VisualEffectConfig(
  backgroundColor: Color(0xFF0A1220),
  foregroundColor: Color(0xFFD7E3F7),
  accentColor: Color(0xFF77F2D7),
  effectColors: <Color>[
    Color(0xFF78F6E2),
    Color(0xFF7DBDFF),
    Color(0xFFD7E3F7),
    Color(0xFF7D7BFF),
    Color(0xFF63F0B7),
  ],
  density: 1.1,
  symbol: '+',
  shape: VisualEffectShape.none,
  baseCellSize: 28,
  minScale: 0.9,
  maxScale: 2.5,
  interactionRadius: 140,
  animationSpeed: 1.0,
  randomMotionStrength: 0.18,
  easing: Curves.easeOutCubic,
  enablePointerInteraction: true,
  enableRipples: true,
  opacity: 1.0,
  padding: EdgeInsets.all(12),
  randomSeed: 7,
);
```

Complete example with every available option:

```dart
const fullConfig = VisualEffectConfig(
  backgroundColor: Color(0xFF08111E),
  foregroundColor: Color(0xFFD8E7FF),
  accentColor: Color(0xFF70F4E1),
  effectColors: <Color>[
    Color(0xFF8AF7E4),
    Color(0xFF77C8FF),
    Color(0xFFD8E7FF),
    Color(0xFF6C8DFF),
    Color(0xFF5AF2B8),
  ],
  density: 1.15,
  symbol: '+',
  shape: VisualEffectShape.none,
  baseCellSize: 28,
  minScale: 0.9,
  maxScale: 2.4,
  interactionRadius: 140,
  animationSpeed: 1.0,
  randomMotionStrength: 0.18,
  easing: Curves.easeOutCubic,
  enablePointerInteraction: true,
  enableRipples: true,
  opacity: 1.0,
  padding: EdgeInsets.all(12),
  randomSeed: 7,
);
```

All built-in effects honor the shared `symbol`, `shape`, `effectColors`, `randomMotionStrength`, `minScale`, `maxScale`, `opacity`, and `enableRipples` settings.

You can then pass it directly into the surface:

```dart
VisualEffectSurface(
  effectName: 'liquidRipple',
  config: fullConfig,
);
```

## Adding custom effects

You can register your own effects globally:

```dart
class MyEffect extends VisualEffect {
  const MyEffect();

  @override
  String get name => 'myEffect';

  @override
  String get displayName => 'My Effect';

  @override
  String get description => 'An app-specific effect.';

  @override
  void paint(
    Canvas canvas,
    VisualEffectConfig config,
    VisualEffectFrame frame,
    VisualEffectDrawingContext context,
  ) {
    // Custom drawing here.
  }
}

void registerEffects() {
  VisualEffects.register(const MyEffect());
}
```

## Example app

The package includes a polished `/example` app that demonstrates:

- switching effects by name and by index
- live controls for density, radius, scale, speed, opacity, arbitrary glyph input, built-in shape selection, palettes, and ripple toggles
- adjustable glass-panel blur so the background effect can be viewed more clearly
- a live copy-pasteable `VisualEffectConfig` snippet that mirrors the current demo settings
- an overlay panel above the animated background
- a clear hover-focused `plusGrid` demo for Flutter web and desktop

Run it locally:

```bash
cd example
flutter run -d chrome
```

## Publish procedure

- Tag the release in git


After a successful publish, create a version tag so the source matches what was uploaded:
```
git add .
git commit -m "Release visual_effects_kit v0.1.4"
git tag v0.1.4
git push
git push origin v0.1.4
```

Replace 0.1.4 with the version you actually published.

## Full command sequence

From the package root, a typical publish flow looks like this:

```
git status
flutter pub get
cd example
flutter pub get
cd ..
dart format lib test example/lib example/test
flutter analyze
flutter test
cd example
flutter test
cd ..
flutter pub publish --dry-run
flutter pub publish
```


## Roadmap

- optional shader-backed effects for high-end surfaces
- layered compositing and blend modes
- effect presets and theme packs
- mask-aware and shape-aware effect adapters
- image and particle-driven hybrid effects
