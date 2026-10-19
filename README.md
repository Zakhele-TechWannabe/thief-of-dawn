# Thief of Dawn

An action platformer set in the owner's **Umbraverse** (lore in Google Drive; story in `STORY.md`). Godot 4.7.
Movement has Prince of Persia's weight and ledge-climbing; combat is fast and readable (combo, dodge roll,
parry); each FATE Mark earned unlocks an ability that opens new routes.

```sh
godot --path .                                   # play: title → intro → vaults → card → mines → card → title
godot -e --path .                                # editor
godot --headless --path . --import               # (re)import assets after adding files
godot --headless --path . -- --level=1 --smoke=1800          # headless random-input test, prints SMOKE OK
godot --headless --path . -- --level=2 --route=tests/routes/level2.seq  # requires the exit's completed signal
./tests/run.sh                                  # serial import, all level smokes/routes, mechanics checks
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
| `src/shade_archer.gd`, `src/shadow_bolt.gd` | violet shade archer: draw-back glint, slow bolt, roll/jump/parry reflection |
| `src/loose_floor.gd` | resettable floor: 0.4 s warning shake → fall → dust on impact |
| `src/shade.gd` | Tenebri shade AI: patrol → chase → wind-up (telegraphed) → strike → recover; block; dissolve |
| `src/camera.gd` | look-ahead follow camera with a vertical dead band and shake |
| `src/hud.gd` | health, area name, toasts, always-on controls bar |
| `src/sprites.gd` | SpriteFrames from `assets/sprites/<actor>/` + `meta.json` (anchor, fps, which way the art faces) |
| `src/fx.gd` | lights, embers, dust, bursts, hit flash |
| `levels/` | level files + `FORMAT.md` (legend and movement numbers) |
| `tools/levels/` | level builder scripts; regenerate with `python tools/levels/build_level<N>.py` |
| `tests/` | exit-proving input routes, serial runner, isolated mechanics integration scene |
| `tools/pixellab.py` | budget-capped PixelLab client; `PIXELLAB_LEDGER=ledger-godot.json` for the second $1 budget |
| `art2/` | Godot-era art generation (`gen.py`) and packaging (`build.py`) |

## Credits

Story and world: the owner's Umbraverse. Art: PixelLab (generated for this game). Fonts: Silkscreen and Pixelify
Sans (SIL Open Font License, `assets/fonts/OFL-*.txt`).

## Levels and development checks

Level 1 is the approved Vaults of Thalor layout. Its route climbs the vault wall, jumps the spike gap,
avoids the gallery shade, rolls through the crypt, and jumps all three final pillars to the door.
No movement tuning or geometry changes were needed to complete it.

Level 2, **The Deep Mines of Norra**, is a 180×40 switchback mine. Three shafts require Traversa's wall jump;
the ore gallery teaches archers, the high haul bridge crumbles into a catch tunnel, and the wet descent
leads to the sump and final shaft. Two flame shrines heal and set checkpoints. A side chimney above the
ore gallery hides an optional big potion. Timber, ore glints, dripping water, lanterns, torches and candles
light the route. Starting with `--level=2` grants Traversa and its maximum-health increase, as normal progression does.
Vitaria currently grants maximum health on the after2 card; second wind remains a future ability.

`--route=path` uses the same **zero-based physics-frame** syntax as `--seq`: `10+move_right`, `40+jump`,
`75-jump`. Put steps on separate lines or separate them with commas. Blank lines and `#` comments are
allowed. Use `--level=N` to select the map (defaults to 1). The route seeds randomness, starts at `@`,
and accepts no `--at`, `--hold` or `--seq` overrides. It prints `ROUTE OK` only on `completed`; death,
invalid input or no completion within 180 frames after the last step prints `ROUTE FAIL` with the player
position and exits 1. There is a 36,000-frame sequence limit. `--trace=30` logs position/state every 30 frames
for authoring routes. Releasing movement and pressing `up` at the door is part of each route.

`tests/run.sh` runs one Godot process at a time and checks exit codes, success markers and script errors.
It uses `--fixed-fps 60` for fast, repeatable headless simulation at the game's normal physics rate, and
keeps temporary editor settings/logs under `/tmp`. The mechanics scene checks the archer's telegraph,
real projectile collisions for parry/reflection, roll and jump, and floor collapse/reset on checkpoint respawn.
Screenshots still use `--shot` and require an accessible display; headless checks do not verify rendering.

For exported builds, include `levels/*.txt` and `story/*.md` in the preset's non-resource include filter.
