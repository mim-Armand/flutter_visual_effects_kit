## 0.1.4

- Added built-in shape rendering with `VisualEffectShape.circle`, `square`, and `star`.
- Updated all built-in effects to render either arbitrary text symbols or vector shapes while keeping the shared config behavior consistent.
- Improved rendering performance by routing shapes through lightweight vector drawing and reducing symbol cache churn.
- Updated the example app with free-form glyph input, shape selection, and copy-paste config output that includes the selected shape.

## 0.1.3

- Made all built-in effects honor the configured `symbol`, shared palette colors, and seeded random motion.
- Added shared ripple response support across the built-in effects and exposed `enableRipples` in `VisualEffectConfig`.
- Added ripple toggles to the example app and updated the generated copy-paste config snippet.

## 0.1.2

- Added adjustable glass-panel blur controls in the example app so effects are easier to inspect.
- Improved the example demo workflow for previewing backgrounds beneath the overlay panels.

## 0.1.1

- Initial release of `visual_effects_kit`.
- Added `VisualEffectSurface` for animated procedural effect backgrounds.
- Added effect lookup by name and by index through `VisualEffects`.
- Added immutable `VisualEffectConfig` and `VisualEffectFrame` models.
- Added built-in `plusGrid`, `dotField`, and `waveGrid` effects.
- Added built-in `liquidRipple` with click or touch ripples and pointer-driven liquid motion.
- Added optional `effectColors` and `randomMotionStrength` config fields.
- Added a responsive example app with live controls.
- Added registry and custom effect extension points.
