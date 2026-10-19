# Thief of Dawn — a tale of the Umbraverse

A complete five-level cinematic platformer in Python and pygame. Kael, a green-skinned Valerin squire, has 45 minutes to recover the Lantern of Eterna before Morrow unwrites the past. Movement has momentum, jumps commit to their takeoff speed, and rooms flip at their boundaries.

## Run

Python 3.12 and pygame 2.6 are used here. No network or extra packages are needed in the supplied environment.

```sh
.venv/bin/python -m game
.venv/bin/pytest -q
```

New Game begins with the story; Continue resumes at the start of the saved level. Progress saves at each level start to `~/.local/share/thief-of-dawn/save.json`. The save carries level, maximum HP, and remaining time. Missing, corrupt, or unwritable saves never crash the game. Headless sessions do not write saves.

## Controls

| Key | Action |
| --- | --- |
| Left / Right | Accelerate into a run; slower steps near an opponent |
| Up | Jump; hold to catch a ledge; press again to climb |
| Shift | Careful step, stop at ledges, safely cross spikes; hold in air to grab |
| Down | Crouch; Down + direction approaches an edge to descend into a hang; press while hanging to drop |
| Z / Space | Sword attack, once the sword is found |
| X | Block; the first 0.22 seconds parries and staggers the attacker |
| Esc | Pause: Resume, Restart room, Controls, Quit to title |
| F11 | Toggle fullscreen |
| M | Mute / unmute |
| Up / Down, Enter | Select menu entries |
| Any key | Reveal a story card, then continue |

Standing forward jumps cover about three tiles; running jumps about five. Release horizontal input before Up for an in-place jump. Catch a three-to-five-tile shelf with Up or Shift, then press Up again. Drops through three tiles are safe; four to six cost one HP and cause a stumble; seven or more kill. Fight with spacing and timed parries; enemies cannot be stomped. Knockback can send either fighter into a trap or pit. Death restores the room-entry checkpoint and its enemies after the death animation; dawn keeps approaching. Pause and story cards stop the timer.

## The levels

The five levels contain **8 / 9 / 10 / 10 / 10 rooms**, each a hand-authored 30×16 ASCII grid. Rooms occupy four map rows, with climbing, safe descents, lethal voids, returning plate routes, and gates controlled from other rooms. World-space fall distance and velocity survive room flips in both directions. Each room has at least two reachable floor heights. Three optional big potions lie in side rooms in levels 2, 3 and 5; small red potions replenish health on descent landings.

See [LEVEL_DESIGN.md](LEVEL_DESIGN.md) for coordinate maps, every room's purpose, the checker's main routes and limitations. The sword alcove is gated by the first level's plate. Norra's bridge release and the final two levels' chained latches prevent skipping their objectives. Valerion's timed run spans two rooms; Vesh and Morrow lock their arena exits until all opponents are defeated. Morrow's exit is on an upper platform.

Readable JSON lives in `data/levels/levelN/level.json`. A plate target is `{"at": [room_x, room_y, col, row], "seconds": 0}`; zero means permanent. Two-element local targets remain supported. Positive timers run across room changes. Room `entry` coordinates are debug starting positions; live transitions keep matching x/y, momentum and fall history. A FATE Mark after each level adds maximum health. Story cards come verbatim from `STORY.md` (paragraph whitespace is normalized).

## CLI and scripted runs

```sh
.venv/bin/python -m game --level 3 --room 2,0 --scale 2 --seed 7
.venv/bin/python -m game --room-sheet level1 screens/level1-rooms.png
.venv/bin/python -m game --level 1 --headless-frames 443 --inputs /tmp/climb.txt --screenshot screens/climb.png
```

- `--level N`: begin directly in level 1–5.
- `--room X,Y`: select a room (used with `--level`, or headless).
- `--scale N`: positive integer nearest-neighbour window scale; default 3.
- `--headless-frames N`: dummy display/audio, exact fixed 60 Hz simulation frames; render the final frame. Prints room, feet position, HP, deaths and time.
- `--room-sheet levelN PATH`: headlessly tile every room at its map coordinates, with room labels.
- `--screenshot PATH`: save the native 480×270 final frame.
- `--inputs PATH`: timed input, in simulation frames. Lines are `FRAME KEY down` or `FRAME KEY up`; keys stay held until released. Comments start with `#`. Use `shift`, `space`, `escape`, `return`, or lowercase arrow/letter names.
- `--seed N`: deterministic enemy decisions.

Example input file which exits the first room of level 1:

```text
0 right down
50 right up
60 up down
100 up up
101 up down
132 up up
132 right down
160 right up
170 up down
210 up up
211 up down
242 up up
242 right down
```

`tests/` covers measured jump and grab physics, vertical momentum, a five-tile climb through the top seam, fall damage across room boundaries, spike/loose-floor behavior, cross-room timers and checkpoints, sword/boss locks, strict pairwise room uniqueness, reachable floor heights, route climb/drop/transition counts, two scripted traversal runs, CLI screenshots, combat, saves and story progression. Each level also receives 3,000 random simulation frames.

The checker uses world-space supports, actual standing/running takeoff speeds, body clearance, jump-plus-grab height, nonlethal falls, collapse edges, sword state, plate state and boss combat objectives. It produces a concrete route rather than retroactively opening every reachable gate. It does not execute fights, cumulative health management or slicer waits; timed gates are considered openable, with the Valerion run separately verified in the real simulation. Room sheets live in git-ignored `screens/`.

## Assets and fallback art

`ASSETS.md` is the engine/art contract. The engine only reads `assets/`; it never writes to it. Every tile, prop, background, title and Mark image is optional. Missing or incomplete PNGs fall back without crashing. Missing actors use cached, articulated figures with correct story palettes and distinct run, jump, hang, climb, attack, block and death poses. Asset files are discovered on first use; restart to discover art completed after that point.

Sprites use the anchor and animation FPS/loop settings in each actor's `meta.json`, face right, and mirror for left. Optional `idle_sword` and `crouch` use available idle art before resorting to procedural figures. Backgrounds and sprite frames are cached; scaling is nearest-neighbour and the window-sized destination surface is reused. Native rendering follows background, scenery, props/traps, actors, floor lips, then HP-triangle/time HUD. Sound effects use cached raw PCM buffers without numpy or sndarray, and gracefully fall silent when no audio device is available.

The current visual effects are intentionally modest: no dynamic shadow renderer, skeletal interpolation, gamepad mapping or music. Saves resume the level start, while room checkpoints last for the current session. There is no mid-room save.

## Credits

Story and characters: the owner's Umbraverse lore. Art: PixelLab via `tools/`, when present. Engine, procedural fallback figures, backgrounds and synthesized effects: this implementation. Inspired by the deliberate movement and cinematic danger of Prince of Persia (1989).

No changes to the art contract are required. Optional future art could add separate slicer open/closed frames and gate-raised art; the current single-image contract represents those states procedurally or by hiding the gate.

Art was generated with **PixelLab**, then reviewed and assembled offline from `art/raw/`.
Total generation cost: **$0.92**. The polish rebuild makes no network calls:

```sh
.venv/bin/python tools/art_build.py
.venv/bin/python tools/benchmark.py
```

Generated art supplies the four actors, five themed tilesets and backgrounds, props,
title and FATE Marks. Shade and Morrow deliberately dissolve from their last hurt
frame into drifting violet particles over 0.8 seconds; they have no authored death
animation. Missing crouch/armed-idle poses reuse idle; missing movement poses use
the engine fallback. Slicer motion and raised gates remain procedural states.
Decorative stone brackets, mine timbers and Dornis eaves are render-only supports.

There are three small healing potions per level: a side reward, a recovery stop
and a final approach. The three large-potion secrets remain in levels 2, 3 and 5.
Idle actor heights are 46 / 46 / 50 / 54 px (Kael / shade / Vesh / Morrow), with
feet at y=60. Frames and their mirrors are cached; decorative architecture is
cached by room layout. Complete backgrounds are displayed without a tiled grid.
`tests/test_playthrough.py` uses the same `InputScript` parser as `--inputs` for
traversal and recorded parry/counterattack combat replays. Fresh room sheets and
the complete before/after opaque bounding-box report are in `screens/`.
