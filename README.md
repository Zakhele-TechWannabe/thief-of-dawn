# Thief of Dawn

A narrative thief platformer set in the owner's **Umbraverse**. Godot 4.7.
The first menu option is **Chapter I — The Boy (playable slice)**: Renn, fifteen,
Slateford, Year 320. **Prototype levels** preserves the separate Kael levels 1–2,
including their sword combat and FATE abilities. Those are technical prototypes,
not Renn's story.

```sh
godot --path .                                   # Chapter I / Prototype levels menu
godot --path . -- --slice                        # directly start Renn’s slice
godot -e --path .                                # editor
godot --headless --path . --import               # (re)import assets after adding files
godot --headless --path . -- --level=1 --smoke=1800          # headless random-input test, prints SMOKE OK
godot --headless --path . -- --level=2 --route=tests/routes/level2.seq  # requires the exit's completed signal
./tests/run.sh                                  # serial import, all level smokes/routes, mechanics checks
godot --path . -- --level=1 --shot=/tmp/a.png --frames=90 \
      --at=1150,384 --seq=20+attack,21-attack              # screenshot after scripted input (opens a window)
```

The pygame prototype that came before lives in `prototype-pygame/` (reference only).

## Chapter I slice

Escape the holding cell through the climbing vent or the low drain, cross the watch
walk/yard, shove Hadrik at the railing, then get over the lower workshop roofs. The
opening exchange establishes Renn's guilt; road-tools glyphs and overheard speech
establish his illiteracy and the first-light transfer. Below the roofs, Ilen's pledged
rope frame waits to be seized. The short end card commits named story flags to
`user://thief_story.json`; checkpoints never undo already committed flags.

Arrows/A/D move · Up/W/Space/Z jump and climb · Down/S crouch · C/Shift slide · X/J
shove or struggle · hold E interact · V throw a pebble or drop the carried object ·
Up at the roof exit · Esc pause · F11 window/fullscreen. Always-on HUD shows exposure,
two quick-tool slots and one carried-object slot. A/Y/B/X and right shoulder provide
jump/interact/slide/shove/throw on a gamepad; D-pad or left stick moves/crouches/climbs.
A shove breaks one lone guard's grab per checkpoint; two guards prevent that escape.
An alert guard facing Renn usually catches a shove. Pebbles are finite but can be
replenished from stone piles; a pry hook speeds work on the vent or grate. Hold
interactions stop progressing when released or moving. Retry restores gates, loot,
guards, inventory and local flags to the stage snapshot. The first lower roof saves
automatically; the yard's blue checkpoint marker requires E.

```sh
godot --headless --fixed-fps 60 --path . -- --slice --smoke=1800
godot --headless --fixed-fps 60 --path . -- --slice --route=tests/slice_routes/vent.seq
godot --headless --fixed-fps 60 --path . -- --slice --route=tests/slice_routes/drain.seq
.venv/bin/python tools/art/recolor.py              # local Pillow recolors; no service calls
python tools/levels/build_chapter1.py             # regenerate authored slice map
```

`src/thief/` contains the independent RennController, WatchGuard awareness,
ThiefInteractable, ThiefCheckpoint, StoryState, DiegeticText, pebble and SliceLevel.
The slice runner uses the same frame press/release syntax as prototype routes, plus
`slice_interact` and `slice_throw`. It starts at the normal spawn, skips only the timed
intro, and succeeds only on the real exit signal. `--trace=30` assists route authoring.
`tests/run.sh` adds both slice routes, random-input smoke and the slice mechanics scene,
sequentially. No second Godot instance is needed.

Art is **stand-in**: `renn_standin` and `renn_standin_ledge` recolor Kael's green skin
to slate blue, dark hair to bronze, and green cloth to grey-brown; `watch_standin`
recolors Vesh to a Norran watch palette. Metadata and anchors are preserved. Renn
still holds a sword in some source frames, and the watch uses Vesh's silhouette;
there is no sword attack in the slice. Scenery uses theme 2 and a procedural dark
skyline. No new art was commissioned. Visual composition, controller hardware and
the intended 10–20-minute first-time pacing need a human playtest; headless routes
are rehearsed fast paths, not playtime measurements.

## Prototype controls (always shown on screen)

Arrows/WASD move · Up/W/Space/Z jump · X/J attack (press again for the second hit) · C/L/Shift dodge-roll ·
V/K parry (block; the first 0.2 s deflects and staggers the attacker, and your next hit is a critical) ·
Up climbs from a ledge and enters doors · Down+Jump drops through a plank · F11 fullscreen/window · F10 move to the next screen (remembered for next launch; or start with `-- --screen 1`) · Esc pause. Starts fullscreen. Gamepad works too.

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
