import 'dart:collection';

import 'dot_field_effect.dart';
import 'liquid_ripple_effect.dart';
import 'plus_grid_effect.dart';
import 'visual_effect.dart';
import 'wave_grid_effect.dart';

/// Mutable registry that stores and resolves visual effects.
class VisualEffectRegistry {
  /// Creates a registry seeded with [effects].
  VisualEffectRegistry([
    Iterable<VisualEffect> effects = const <VisualEffect>[],
  ]) {
    for (final effect in effects) {
      register(effect);
    }
  }

  final List<VisualEffect> _effects = <VisualEffect>[];
  final Map<String, int> _indexByName = <String, int>{};

  /// Registered effects in insertion order.
  List<VisualEffect> get effects =>
      UnmodifiableListView<VisualEffect>(_effects);

  /// Returns the effect matching [name], or `null` if none exists.
  VisualEffect? effectByName(String name) {
    final index = _indexByName[_normalize(name)];
    if (index == null) {
      return null;
    }
    return _effects[index];
  }

  /// Returns the effect at [index], or `null` if it is out of range.
  VisualEffect? effectByIndex(int index) {
    if (index < 0 || index >= _effects.length) {
      return null;
    }
    return _effects[index];
  }

  /// Registers or replaces an effect with the same name.
  void register(VisualEffect effect) {
    final normalizedName = _normalize(effect.name);
    final existingIndex = _indexByName[normalizedName];
    if (existingIndex != null) {
      _effects[existingIndex] = effect;
      return;
    }

    _effects.add(effect);
    _indexByName[normalizedName] = _effects.length - 1;
  }

  /// Removes an effect by name.
  bool unregister(String name) {
    final normalizedName = _normalize(name);
    final existingIndex = _indexByName.remove(normalizedName);
    if (existingIndex == null) {
      return false;
    }

    _effects.removeAt(existingIndex);
    _reindex();
    return true;
  }

  /// Resolves the active effect using name, index, or the default first entry.
  VisualEffect resolve({String? effectName, int? effectIndex}) {
    if (_effects.isEmpty) {
      throw StateError('VisualEffectRegistry has no registered effects.');
    }

    if (effectName != null) {
      return effectByName(effectName) ?? _effects.first;
    }
    if (effectIndex != null) {
      return effectByIndex(effectIndex) ?? _effects.first;
    }
    return _effects.first;
  }

  static String _normalize(String value) => value.trim().toLowerCase();

  void _reindex() {
    _indexByName
      ..clear()
      ..addEntries(
        _effects.asMap().entries.map(
              (entry) => MapEntry<String, int>(
                  _normalize(entry.value.name), entry.key),
            ),
      );
  }
}

/// Global access to built-in and user-registered effects.
abstract final class VisualEffects {
  static final VisualEffectRegistry _registry = VisualEffectRegistry(
    const <VisualEffect>[
      PlusGridEffect(),
      DotFieldEffect(),
      WaveGridEffect(),
      LiquidRippleEffect(),
    ],
  );

  /// All currently available effects in registry order.
  static List<VisualEffect> get availableEffects => _registry.effects;

  /// Stable effect names in registry order.
  static List<String> get effectNames => <String>[
        for (final effect in availableEffects) effect.name,
      ];

  /// Number of available effects.
  static int get effectCount => availableEffects.length;

  /// Looks up an effect by [name].
  static VisualEffect? effectByName(String name) =>
      _registry.effectByName(name);

  /// Looks up an effect by [index].
  static VisualEffect? effectByIndex(int index) =>
      _registry.effectByIndex(index);

  /// Resolves an effect using the package selection rules.
  static VisualEffect resolve({String? effectName, int? effectIndex}) {
    return _registry.resolve(effectName: effectName, effectIndex: effectIndex);
  }

  /// Registers a custom or replacement effect globally.
  static void register(VisualEffect effect) => _registry.register(effect);

  /// Removes a custom or built-in effect by name.
  static bool unregister(String effectName) => _registry.unregister(effectName);
}
