# Embervale Relics (Godot 4.7.2)

The real game. Open this folder in **Godot 4.7.2** (`project.godot`) and press **F5**.

Original painted sprites (hero, relics, enemies, dusk vale) were keyed, cropped, and imported as nearest-neighbor pixel art. Collision tiles are crisp 16×16 so platforms stay fair.

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
