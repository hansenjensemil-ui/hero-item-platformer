# Embervale Relics (Godot 4.7.2)

The real game. Open `project.godot` in **Godot 4.7.2** and press **F5**.

Uses the **GL Compatibility** renderer (not Forward Plus) so the editor can start on Linux without Vulkan.

Sprites are embedded PNG bytes in `scripts/ArtData.gd`. Art.gd loads only those bytes, with a procedural sky fallback. Do not add `.b64` files or pixel-rect SVGs — GitHub truncates `.b64`, and hundreds of 1×1 `<rect>` fills crash Godot 4.7.2's importer the moment the project is opened.

## Controls

- Run: Left/Right or A/D
- Jump (hold for height): Space, W, or Up
- Attack: J, K, or X
- Title / continue / respawn: Enter or Space / R

## Relics

- Heartstone: +4 max HP and a full heal
- Windstep Boots: +100 run speed
- Skyroot Feather: stronger jump
- Emberblade: attack 1 → 3 (needed for stone brutes)

HUD shows HP / SPD / JMP / ATK. A toast fires on pickup.

## The vale

Ashgrove → Thorn Pit → Wind Stair (boots) → Skyroot Tower (feather) → Ember Court (blade + checkpoint) → Speed Canyon → Brute Keep → shrine banner.

Death respawns at the last checkpoint with relics kept.
