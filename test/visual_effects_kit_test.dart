import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:visual_effects_kit/visual_effects_kit.dart';

void main() {
  test('registry lookup by effect name resolves built-in effects', () {
    expect(VisualEffects.effectByName('plusGrid')?.name, 'plusGrid');
    expect(VisualEffects.effectByName('PLUSGRID')?.name, 'plusGrid');
    expect(VisualEffects.effectByName('dotField')?.displayName, 'Dot Field');
  });

  test('registry lookup by index resolves built-in effects', () {
    expect(VisualEffects.effectByIndex(0)?.name, 'plusGrid');
    expect(VisualEffects.effectByIndex(1)?.name, 'dotField');
    expect(VisualEffects.effectByIndex(2)?.name, 'waveGrid');
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
      baseCellSize: 30,
      padding: EdgeInsets.all(12),
    );

    final copied = config.copyWith(
      density: 1.6,
      symbol: '*',
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    );

    expect(
      copied,
      const VisualEffectConfig(
        density: 1.6,
        symbol: '*',
        baseCellSize: 30,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
    expect(copied, isNot(config));
    expect(copied.baseCellSize, config.baseCellSize);
  });
}
