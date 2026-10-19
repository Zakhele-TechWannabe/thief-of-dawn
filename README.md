# Thief of Dawn

An action platformer set in the owner's **Umbraverse** (lore in Google Drive; story in `STORY.md`). Godot 4.7.
Movement has Prince of Persia's weight and ledge-climbing; combat is fast and readable (combo, dodge roll,
parry); each FATE Mark earned unlocks an ability that opens new routes.

```sh
godot --path .                                   # play
godot -e --path .                                # editor
godot --headless --path . --import               # (re)import assets after adding files
godot --headless --path . -- --level=1 --smoke=1800          # headless random-input test, prints SMOKE OK
godot --path . -- --level=1 --shot=/tmp/a.png --frames=90 \
      --at=1150,384 --seq=20+attack,21-attack              # screenshot after scripted input (opens a window)
```

The pygame prototype that came before lives in `prototype-pygame/` (reference only).

## Controls (always shown on screen)

Arrows/WASD move · Up/W/Space/Z jump · X/J attack (press again for the second hit) · C/L/Shift dodge-roll ·
V/K parry (block; the first 0.2 s deflects and staggers the attacker, and your next hit is a critical) ·
Up climbs from a ledge and enters doors · Down+Jump drops through a plank · F11 fullscreen/window · Esc pause. Starts fullscreen. Gamepad works too.

## Layout

| path | what |
|---|---|
| `project.godot` | 640×360 viewport, integer scaling, nearest filtering: crisp pixels at any window size |
| `src/game.gd` | autoload: input map, progress (max HP, FATE marks → abilities), hit-stop, shake, pixel fonts |
| `src/main.gd` | flow (title → story card → level → card), pause, screenshot and smoke modes |
| `src/level.gd` | builds a level from `levels/*.txt`: tiles, parallax, lights, decor, hazards, pickups, enemies |
| `src/player.gd` | Kael: state machine (move, attack combo, roll, block/parry, hurt, hang, climb, dead) |
| `src/shade.gd` | Tenebri shade AI: patrol → chase → wind-up (telegraphed) → strike → recover; block; dissolve |
| `src/camera.gd` | look-ahead follow camera with a vertical dead band and shake |
| `src/hud.gd` | health, area name, toasts, always-on controls bar |
| `src/sprites.gd` | SpriteFrames from `assets/sprites/<actor>/` + `meta.json` (anchor, fps, which way the art faces) |
| `src/fx.gd` | lights, embers, dust, bursts, hit flash |
| `levels/` | level files + `FORMAT.md` (legend and movement numbers) |
| `tools/levels/` | level builder scripts |
| `tools/pixellab.py` | budget-capped PixelLab client; `PIXELLAB_LEDGER=ledger-godot.json` for the second $1 budget |
| `art2/` | Godot-era art generation (`gen.py`) and packaging (`build.py`) |

## Credits

Story and world: the owner's Umbraverse. Art: PixelLab (generated for this game). Fonts: Silkscreen and Pixelify
Sans (SIL Open Font License, `assets/fonts/OFL-*.txt`).
