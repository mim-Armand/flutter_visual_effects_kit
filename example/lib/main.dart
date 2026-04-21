import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:visual_effects_kit/visual_effects_kit.dart';

void main() {
  runApp(const VisualEffectsKitExampleApp());
}

class VisualEffectsKitExampleApp extends StatelessWidget {
  const VisualEffectsKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'visual_effects_kit',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5FD7C8),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF07101B),
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.onDrag,
        ),
      ),
      home: const _DemoPage(),
    );
  }
}

Color _fade(Color color, double opacity) {
  return color.withAlpha((opacity * 255).round().clamp(0, 255));
}

enum _SelectionMode { name, byIndex }

class _DemoPage extends StatefulWidget {
  const _DemoPage();

  @override
  State<_DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<_DemoPage> {
  static const List<_PaletteOption> _palettes = <_PaletteOption>[
    _PaletteOption(
      name: 'Aurora Glass',
      background: Color(0xFF08111E),
      foreground: Color(0xFFD7E6FB),
      accent: Color(0xFF70F4E1),
    ),
    _PaletteOption(
      name: 'Warm Ember',
      background: Color(0xFF180E0A),
      foreground: Color(0xFFF8DEC8),
      accent: Color(0xFFFF8E6E),
    ),
    _PaletteOption(
      name: 'Soft Mist',
      background: Color(0xFFF3F5F9),
      foreground: Color(0xFF3E516B),
      accent: Color(0xFF00889A),
    ),
  ];

  static const List<String> _symbols = <String>['+', '×', '*', '•'];

  _SelectionMode _selectionMode = _SelectionMode.name;
  String _selectedEffectName = VisualEffects.effectNames.first;
  int _selectedEffectIndex = 0;
  _PaletteOption _palette = _palettes.first;
  String _symbol = '+';
  double _density = 1.1;
  double _radius = 150;
  double _maxScale = 2.5;
  double _speed = 1.0;
  double _opacity = 1.0;
  bool _interactive = true;
  bool _repaintContinuously = true;

  @override
  Widget build(BuildContext context) {
    final currentEffect = _selectionMode == _SelectionMode.name
        ? VisualEffects.resolve(effectName: _selectedEffectName)
        : VisualEffects.resolve(effectIndex: _selectedEffectIndex);

    final config = VisualEffectConfig(
      backgroundColor: _palette.background,
      foregroundColor: _palette.foreground,
      accentColor: _palette.accent,
      density: _density,
      symbol: _symbol,
      maxScale: _maxScale,
      interactionRadius: _radius,
      animationSpeed: _speed,
      opacity: _opacity,
      padding: const EdgeInsets.all(12),
    );

    return Scaffold(
      body: VisualEffectSurface(
        effectName:
            _selectionMode == _SelectionMode.name ? _selectedEffectName : null,
        effectIndex: _selectionMode == _SelectionMode.byIndex
            ? _selectedEffectIndex
            : null,
        interactive: _interactive,
        repaintContinuously: _repaintContinuously,
        config: config,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final wide = constraints.maxWidth >= 1024;
              final content = wide
                  ? Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 12, 24),
                            child: _HeroPanel(
                              currentEffect: currentEffect,
                              selectionMode: _selectionMode,
                              selectedEffectIndex: _selectedEffectIndex,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 380,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 24, 24, 24),
                            child: _ControlsPanel(
                              selectionMode: _selectionMode,
                              selectedEffectName: _selectedEffectName,
                              selectedEffectIndex: _selectedEffectIndex,
                              palette: _palette,
                              symbol: _symbol,
                              density: _density,
                              radius: _radius,
                              maxScale: _maxScale,
                              speed: _speed,
                              opacity: _opacity,
                              interactive: _interactive,
                              repaintContinuously: _repaintContinuously,
                              palettes: _palettes,
                              symbols: _symbols,
                              onSelectionModeChanged: (mode) {
                                setState(() {
                                  _selectionMode = mode;
                                });
                              },
                              onEffectNameChanged: (name) {
                                setState(() {
                                  _selectedEffectName = name;
                                  _selectedEffectIndex =
                                      VisualEffects.effectNames.indexOf(name);
                                });
                              },
                              onEffectIndexChanged: (index) {
                                setState(() {
                                  _selectedEffectIndex = index;
                                  _selectedEffectName =
                                      VisualEffects.effectNames[index];
                                });
                              },
                              onPaletteChanged: (palette) {
                                setState(() {
                                  _palette = palette;
                                });
                              },
                              onSymbolChanged: (symbol) {
                                setState(() {
                                  _symbol = symbol;
                                });
                              },
                              onDensityChanged: (value) {
                                setState(() {
                                  _density = value;
                                });
                              },
                              onRadiusChanged: (value) {
                                setState(() {
                                  _radius = value;
                                });
                              },
                              onMaxScaleChanged: (value) {
                                setState(() {
                                  _maxScale = value;
                                });
                              },
                              onSpeedChanged: (value) {
                                setState(() {
                                  _speed = value;
                                });
                              },
                              onOpacityChanged: (value) {
                                setState(() {
                                  _opacity = value;
                                });
                              },
                              onInteractiveChanged: (value) {
                                setState(() {
                                  _interactive = value;
                                });
                              },
                              onRepaintContinuouslyChanged: (value) {
                                setState(() {
                                  _repaintContinuously = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: <Widget>[
                          _HeroPanel(
                            currentEffect: currentEffect,
                            selectionMode: _selectionMode,
                            selectedEffectIndex: _selectedEffectIndex,
                          ),
                          const SizedBox(height: 18),
                          _ControlsPanel(
                            selectionMode: _selectionMode,
                            selectedEffectName: _selectedEffectName,
                            selectedEffectIndex: _selectedEffectIndex,
                            palette: _palette,
                            symbol: _symbol,
                            density: _density,
                            radius: _radius,
                            maxScale: _maxScale,
                            speed: _speed,
                            opacity: _opacity,
                            interactive: _interactive,
                            repaintContinuously: _repaintContinuously,
                            palettes: _palettes,
                            symbols: _symbols,
                            onSelectionModeChanged: (mode) {
                              setState(() {
                                _selectionMode = mode;
                              });
                            },
                            onEffectNameChanged: (name) {
                              setState(() {
                                _selectedEffectName = name;
                                _selectedEffectIndex =
                                    VisualEffects.effectNames.indexOf(name);
                              });
                            },
                            onEffectIndexChanged: (index) {
                              setState(() {
                                _selectedEffectIndex = index;
                                _selectedEffectName =
                                    VisualEffects.effectNames[index];
                              });
                            },
                            onPaletteChanged: (palette) {
                              setState(() {
                                _palette = palette;
                              });
                            },
                            onSymbolChanged: (symbol) {
                              setState(() {
                                _symbol = symbol;
                              });
                            },
                            onDensityChanged: (value) {
                              setState(() {
                                _density = value;
                              });
                            },
                            onRadiusChanged: (value) {
                              setState(() {
                                _radius = value;
                              });
                            },
                            onMaxScaleChanged: (value) {
                              setState(() {
                                _maxScale = value;
                              });
                            },
                            onSpeedChanged: (value) {
                              setState(() {
                                _speed = value;
                              });
                            },
                            onOpacityChanged: (value) {
                              setState(() {
                                _opacity = value;
                              });
                            },
                            onInteractiveChanged: (value) {
                              setState(() {
                                _interactive = value;
                              });
                            },
                            onRepaintContinuouslyChanged: (value) {
                              setState(() {
                                _repaintContinuously = value;
                              });
                            },
                          ),
                        ],
                      ),
                    );

              return AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      _fade(_palette.background, 0.85),
                      _fade(_palette.accent, 0.08),
                      _palette.background,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: content,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.currentEffect,
    required this.selectionMode,
    required this.selectedEffectIndex,
  });

  final VisualEffect currentEffect;
  final _SelectionMode selectionMode;
  final int selectedEffectIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _InfoChip(
                  label: 'Mode',
                  value: selectionMode == _SelectionMode.name
                      ? 'effectName'
                      : 'effectIndex',
                ),
                _InfoChip(label: 'Current', value: currentEffect.displayName),
                _InfoChip(label: 'Index', value: '$selectedEffectIndex'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Procedural motion for modern Flutter surfaces.',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              currentEffect.description,
              style: theme.textTheme.titleMedium?.copyWith(
                color: _fade(Colors.white, 0.78),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Move your cursor through the background to feel the premium hover response in plusGrid, or drag on touch devices to nudge the effects in motion.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _fade(Colors.white, 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: _fade(Colors.white, 0.07),
                border: Border.all(color: _fade(Colors.white, 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Built for web, desktop, and touch-friendly fallbacks.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'The package uses only Flutter primitives in v1, so you can ship it today and still leave room for future shader-powered upgrades.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _fade(Colors.white, 0.72),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.selectionMode,
    required this.selectedEffectName,
    required this.selectedEffectIndex,
    required this.palette,
    required this.symbol,
    required this.density,
    required this.radius,
    required this.maxScale,
    required this.speed,
    required this.opacity,
    required this.interactive,
    required this.repaintContinuously,
    required this.palettes,
    required this.symbols,
    required this.onSelectionModeChanged,
    required this.onEffectNameChanged,
    required this.onEffectIndexChanged,
    required this.onPaletteChanged,
    required this.onSymbolChanged,
    required this.onDensityChanged,
    required this.onRadiusChanged,
    required this.onMaxScaleChanged,
    required this.onSpeedChanged,
    required this.onOpacityChanged,
    required this.onInteractiveChanged,
    required this.onRepaintContinuouslyChanged,
  });

  final _SelectionMode selectionMode;
  final String selectedEffectName;
  final int selectedEffectIndex;
  final _PaletteOption palette;
  final String symbol;
  final double density;
  final double radius;
  final double maxScale;
  final double speed;
  final double opacity;
  final bool interactive;
  final bool repaintContinuously;
  final List<_PaletteOption> palettes;
  final List<String> symbols;
  final ValueChanged<_SelectionMode> onSelectionModeChanged;
  final ValueChanged<String> onEffectNameChanged;
  final ValueChanged<int> onEffectIndexChanged;
  final ValueChanged<_PaletteOption> onPaletteChanged;
  final ValueChanged<String> onSymbolChanged;
  final ValueChanged<double> onDensityChanged;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<double> onMaxScaleChanged;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<bool> onInteractiveChanged;
  final ValueChanged<bool> onRepaintContinuouslyChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Controls',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Switch effects by name or index and tune the scene in real time.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _fade(Colors.white, 0.7),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SegmentedButton<_SelectionMode>(
                segments: const <ButtonSegment<_SelectionMode>>[
                  ButtonSegment<_SelectionMode>(
                    value: _SelectionMode.name,
                    label: Text('By name'),
                    icon: Icon(Icons.tag_rounded),
                  ),
                  ButtonSegment<_SelectionMode>(
                    value: _SelectionMode.byIndex,
                    label: Text('By index'),
                    icon: Icon(Icons.pin_outlined),
                  ),
                ],
                selected: <_SelectionMode>{selectionMode},
                onSelectionChanged: (selection) {
                  onSelectionModeChanged(selection.first);
                },
              ),
              const SizedBox(height: 16),
              if (selectionMode == _SelectionMode.name)
                DropdownButtonFormField<String>(
                  initialValue: selectedEffectName,
                  decoration: const InputDecoration(
                    labelText: 'Effect name',
                    border: OutlineInputBorder(),
                  ),
                  items: VisualEffects.availableEffects
                      .map(
                        (effect) => DropdownMenuItem<String>(
                          value: effect.name,
                          child: Text('${effect.displayName} (${effect.name})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onEffectNameChanged(value);
                    }
                  },
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: selectedEffectIndex,
                  decoration: const InputDecoration(
                    labelText: 'Effect index',
                    border: OutlineInputBorder(),
                  ),
                  items: List<DropdownMenuItem<int>>.generate(
                    VisualEffects.effectCount,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        '$index • ${VisualEffects.availableEffects[index].displayName}',
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      onEffectIndexChanged(value);
                    }
                  },
                ),
              const SizedBox(height: 20),
              Text(
                'Palette',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: palettes.map((option) {
                  final selected = option == palette;
                  return ChoiceChip(
                    label: Text(option.name),
                    selected: selected,
                    onSelected: (_) => onPaletteChanged(option),
                    avatar: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: <Color>[option.background, option.accent],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Symbol',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: symbols.map((item) {
                  return ChoiceChip(
                    label: Text(item, style: const TextStyle(fontSize: 18)),
                    selected: symbol == item,
                    onSelected: (_) => onSymbolChanged(item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              _SliderRow(
                label: 'Density',
                value: density,
                min: 0.6,
                max: 2.2,
                onChanged: onDensityChanged,
              ),
              _SliderRow(
                label: 'Interaction radius',
                value: radius,
                min: 60,
                max: 220,
                divisions: 16,
                onChanged: onRadiusChanged,
              ),
              _SliderRow(
                label: 'Max scale',
                value: maxScale,
                min: 1.2,
                max: 3.2,
                onChanged: onMaxScaleChanged,
              ),
              _SliderRow(
                label: 'Animation speed',
                value: speed,
                min: 0.2,
                max: 2.4,
                onChanged: onSpeedChanged,
              ),
              _SliderRow(
                label: 'Opacity',
                value: opacity,
                min: 0.35,
                max: 1,
                onChanged: onOpacityChanged,
              ),
              const SizedBox(height: 6),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: interactive,
                title: const Text('Pointer interaction'),
                subtitle: const Text('Enable hover and drag response'),
                onChanged: onInteractiveChanged,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: repaintContinuously,
                title: const Text('Continuous repaint'),
                subtitle: const Text('Turn off to save work when idle'),
                onChanged: onRepaintContinuouslyChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label • ${value.toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions ?? 24,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: _fade(Colors.white, 0.08),
            border: Border.all(color: _fade(Colors.white, 0.16)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _fade(Colors.black, 0.22),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: _fade(Colors.white, 0.08),
        border: Border.all(color: _fade(Colors.white, 0.12)),
      ),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: _fade(Colors.white, 0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteOption {
  const _PaletteOption({
    required this.name,
    required this.background,
    required this.foreground,
    required this.accent,
  });

  final String name;
  final Color background;
  final Color foreground;
  final Color accent;
}
