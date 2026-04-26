import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:visual_effects_kit/visual_effects_kit.dart';

void main() {
  test('registry lookup by effect name resolves built-in effects', () {
    expect(VisualEffects.effectByName('plusGrid')?.name, 'plusGrid');
    expect(VisualEffects.effectByName('PLUSGRID')?.name, 'plusGrid');
    expect(VisualEffects.effectByName('dotField')?.displayName, 'Dot Field');
    expect(
      VisualEffects.effectByName('liquidRipple')?.displayName,
      'Liquid Ripple',
    );
  });

  test('registry lookup by index resolves built-in effects', () {
    expect(VisualEffects.effectByIndex(0)?.name, 'plusGrid');
    expect(VisualEffects.effectByIndex(1)?.name, 'dotField');
    expect(VisualEffects.effectByIndex(2)?.name, 'waveGrid');
    expect(VisualEffects.effectByIndex(3)?.name, 'liquidRipple');
    expect(VisualEffects.effectByIndex(42), isNull);
  });

  test('effect resolution falls back to the first effect', () {
    final fallback = VisualEffects.availableEffects.first;

    expect(VisualEffects.resolve(effectName: 'missing').name, fallback.name);
    expect(VisualEffects.resolve(effectIndex: -1).name, fallback.name);
    expect(VisualEffects.resolve().name, fallback.name);
  });

  test('config copyWith preserves equality semantics', () {
    const config = VisualEffectConfig(
      density: 1.2,
      symbol: 'x',
      shape: VisualEffectShape.circle,
      baseCellSize: 30,
      effectColors: <Color>[Color(0xFF112233), Color(0xFF445566)],
      randomMotionStrength: 0.24,
      enableRipples: false,
      padding: EdgeInsets.all(12),
    );

    final copied = config.copyWith(
      density: 1.6,
      symbol: '*',
      shape: VisualEffectShape.star,
      effectColors: const <Color>[Color(0xFF778899), Color(0xFFAABBCC)],
      randomMotionStrength: 0.38,
      enableRipples: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    );

    expect(
      copied,
      const VisualEffectConfig(
        density: 1.6,
        symbol: '*',
        shape: VisualEffectShape.star,
        baseCellSize: 30,
        effectColors: <Color>[Color(0xFF778899), Color(0xFFAABBCC)],
        randomMotionStrength: 0.38,
        enableRipples: true,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
    expect(copied, isNot(config));
    expect(copied.baseCellSize, config.baseCellSize);
    expect(copied.effectColors, isNot(same(config.effectColors)));
    expect(config.shape, VisualEffectShape.circle);
    expect(copied.shape, VisualEffectShape.star);
    expect(config.enableRipples, isFalse);
    expect(copied.enableRipples, isTrue);
  });
}
