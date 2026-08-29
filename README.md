# Embervale Relics

A short 2D browser platformer. Collect four relics; each one changes how you move, jump, survive, or fight.

Vanilla HTML, CSS, and Canvas. Open index.html in a browser to play.

## How to run

Open index.html in Chrome, Firefox, Edge, or Safari. file:// is enough.

If local scripts are blocked, serve the folder:

    python3 -m http.server 8080

Then open http://localhost:8080

## Controls

- Run: Left/Right or A/D
- Jump (hold for higher): Space, W, or Up
- Attack: J, K, X, or Ctrl
- Start / continue: Enter or Space
- Restart after death or win: R or Enter

Click the canvas once if keys do nothing.

## Relics

Items bob and glow. A toast appears on pickup and the HUD updates at once.

- Heartstone (red heart): +4 max HP and a full heal.
- Windstep Boots (cyan): +100 run speed. Wide gaps become realistic.
- Skyroot Feather (gold): stronger jump. High ledges open up.
- Emberblade (orange sword): attack damage 1 to 3. Brutes fall in two hits.

Base HUD stats: HP 6/6, SPD 220, JMP 700, ATK 1.

## The vale

One continuous level: Ashgrove, Thorn Pit, Wind Stair, Skyroot Tower, Ember Court (checkpoint), Speed Canyon, Brute Keep, then the shrine banner.

Falling, spikes, or zero HP kills you. Respawn at the last checkpoint with relics kept and HP restored.

Tap jump for a hop, hold for a full leap. Stomp slimes and brutes; bats still hurt from above.

## Files

- index.html — page shell
- css/style.css — layout around the canvas
- js/game.js — level, physics, combat, drawing, audio
