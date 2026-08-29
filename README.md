# Embervale Relics

**Godot 4.7.2 is the real game.** Open `godot/project.godot` in **Godot 4.7.2**, then press **F5**.

Original painted sprites (hero, relics, enemies, dusk vale) were keyed, cropped, and imported as nearest-neighbor pixel art. Collision tiles are crisp 16×16 so platforms stay fair.

Sprites are SVG files under `godot/assets/` plus embedded PNG bytes in `godot/scripts/ArtData.gd`. Art.gd loads PNG, then SVG, then ArtData, then a placeholder. It never opens `.b64` files. Those were removed because GitHub truncated them (sky.b64 was 1 byte short / incorrect padding) and `Marshalls.base64_to_raw` on the invalid data crashed the Godot editor when Title loaded sky/hero at launch.

The HTML Canvas version is still at `index.html` if you want the browser build.

## How to run (Godot)

1. Install [Godot 4.7.2](https://godotengine.org/download).
2. Open the `godot/` folder (or `godot/project.godot`) in the editor.
3. Press **F5**.

No export templates required — play from the editor.

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

Base stats: HP 6/6, SPD 220, JMP 700, ATK 1.

## The vale

Ashgrove → Thorn Pit → Wind Stair (boots) → Skyroot Tower (feather) → Ember Court (blade + checkpoint) → Speed Canyon → Brute Keep → shrine banner.

Death respawns at the last checkpoint with relics kept.

Stomp slimes. Bats still hurt from above. Brutes need the Emberblade.

## HTML version

Vanilla HTML, CSS, and Canvas. Open `index.html` in a browser (`file://` is enough).

If local scripts are blocked:

    python3 -m http.server 8080

Then open http://localhost:8080

- `index.html` — page shell
- `css/style.css` — layout around the canvas
- `js/engine.js` — level, physics, combat
- `js/draw.js` — rendering, HUD, screens, loop
