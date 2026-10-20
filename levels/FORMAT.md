# Level file format

A level is a text file: a header of `key: value` lines, then `map:` and the grid. One character = one 16×16 tile.
The grid can be any size; rows may differ in length (missing cells count as wall). Build levels with a script in
`tools/levels/` (see `build_level1.py`) so they stay easy to edit, and commit the generated `.txt`.

## Header

| key | meaning |
|---|---|
| `name` | Shown large on arrival and small in the HUD corner |
| `theme` | Which `assets/tiles/level<N>/` and `assets/backgrounds/level<N>.png` to use (1–5) |
| `darkness` | CanvasModulate colour: how dark the unlit scene is (e.g. `#4a4e68`) |
| `stone` | Tint for the masonry (default `#9a8f9c`) |
| `hint1`…`hint9` | Text for the hint stones `1`…`9` |

## Legend

| char | what | notes |
|---|---|---|
| `#` | solid stone | auto-shaded: walkable top edge where air is above; darker the deeper inside the mass |
| `=` | one-way plank | stand on it, jump up through it, `DOWN+SPACE` drops through |
| `.` | air | |
| `@` | Kael's start | feet at the bottom of the cell; also the first checkpoint |
| `a` | shade archer | keeps distance; violet 0.6 s draw glint; slow bolt can be jumped, rolled through or parried back; 2 HP, no melee block |
| `L` | loose floor | solid slab; shakes after contact for ~0.4 s, then falls and breaks with dust; all slabs restore on checkpoint respawn |
| `r` | dripping water | background drips and faint blue light; no collision |
| `o` | ore glint | small sparkling mineral and blue light; no collision |
| `T` | timber prop | background beam/brace extends to floor; no collision |
| `s` | Tenebri shade | patrols, chases, telegraphed strike, can block; dissolves on death |
| `^` | spikes | 1 damage and back to the last safe ground (not a full restart) |
| `h` / `H` | small potion (+2 health) / big potion (+1 max health) | |
| `k` | flame shrine | checkpoint + full heal |
| `E` | exit door | `UP` while standing in front completes the level |
| `1`–`9` | hint stone | shows `hintN` when Kael walks past |
| `t` | wall torch | warm flickering light + embers |
| `l` | hanging lantern | chain runs up to the ceiling above it |
| `w` | tall window | cold light shaft with dust motes |
| `|` | background column | from this cell down to the floor below it |
| `b` | bookshelf | background decor, procedural spines |
| `c` | candles | floor decor with a small warm light |

## Movement numbers (design levels around these)

Kael is ~3 tiles tall (collision 14×50 px).

- Jump apex ≈ 5.5 tiles. A wall up to **5 tiles** can be jumped onto directly.
- With a ledge grab, a wall up to **8 tiles** can be climbed (hands reach ~3 tiles above the feet at the apex).
  A grab needs the 3 tiles above the ledge top to be open.
- A running jump clears a gap of about **7 tiles** at the same height; keep required gaps ≤ 6.
- No fall damage; spikes and bottomless drops are the hazards.
- A corridor needs at least 4 tiles of headroom to walk; 5+ to jump comfortably.

## Mine layout notes

`L` used to mean lantern in the foundation; both builders now use lowercase `l` for lanterns.
Loose floors are individual dynamic bodies, not stone tiles: they cannot be ledge-grabbed and never become
the spike/pit recovery position. Their warning only shakes the drawing, leaving collision stable until
collapse. A full death/respawn at a checkpoint restores every slab; a nonfatal spike recovery does not.
Shades treat intact slabs as floor and stop at a missing slab.

With Traversa, a fresh jump press against an airborne wall kicks Kael away at (210, -430) px/s.
The three required mine shafts are 4 tiles wide and rise 12 tiles (too high for a normal jump + grab).
There are no intermediate platforms that bypass wall jumping. The optional ore chimney is taller, with
a left-hand lip to reach the big potion; hold left at the top to grab it. Timed input routes in
`tests/routes/levelN.seq` prove the required path without teleporting or changing the physics.

Regenerate both maps with their corresponding `tools/levels/build_levelN.py`. Run `tests/run.sh` after
changes; it imports assets first and runs each level's smoke test and each committed route sequentially.

## Chapter I slice (`levels/chapter1.txt`)

Built by `python tools/levels/build_chapter1.py`. `SliceLevel` reuses `Level` parsing,
16 px tile collision, theme-2 stone/timber, lanterns, candles and torches. It replaces
prototype actors and background with Renn, watchmen and a procedural predawn skyline.
This vocabulary is scoped to the slice; prototype maps keep their existing meanings.

| Character | Slice meaning |
|---|---|
| `#`, `=`, `.` | Solid stone, one-way timber, air (unchanged) |
| `@` | Renn's feet/start and initial stage snapshot |
| `g` | Watchman; patrol points from the header |
| `B` | Hadrik; watchman sprite with cool tint, authored railing opportunity |
| `t`, `l`, `c` | Torch, lantern, candles; visible warm pools also feed the awareness light map |
| `T`, `r` | Timber brace, drain water decor (unchanged) |
| `v` | Hold interaction: loose vent hinge and tall vent gate; records `escape_route=vent` |
| `d` | Hold interaction: drain grate, 32 px opening; records `escape_route=drain` |
| `p` | Watchman's table with coin pouch; two-second steal, observation alerts immediately |
| `q` | Pry hook, second quick-tool slot; speeds hinge/grate work |
| `o` | Loose stones; replenish one pebble if a tool slot is free |
| `u` | Foreground crate cover; crouching within its bounds reduces exposure |
| `n` | Work-transfer notice: fixed glyph vocabulary and crossed road-tools sketch |
| `k` | Stage checkpoint; hold E in the yard, automatic on first lower roof |
| `R` | Railing; a nearby shove embarrasses Hadrik without killing him |
| `E` | Roof exit; UP completes after the railing encounter |

`patrol_<column>_<row>: c,r;c,r;...` supplies an ordered loop of tile-foot positions
for the guard on that cell. All guards stop at unsupported edges; investigations and
chases use the last position actually seen/heard. They do not pathfind between floors.
Light exposure is radial falloff over 130 px, blocked by solid collision; the baseline
is shadow. Cones use the same wall raycasts as perception. Noise has distance falloff;
shouts inform only guards within 240 px of the shouting guard.

The cell furniture can be climbed to the vent. That route crosses the lit upper walk,
its table, a patrol and the unreadable notice. The low drain passes beneath the walk,
with water, a different pouch and a crate before emerging beside the yard patrol.
Both join at Hadrik's railing, then climb workshop steps onto five lower roofs, with
catch awnings below gaps, a new checkpoint, cover, stones and a final roof watchman.
Committed StoryState flags are outside stage snapshots. Snapshots restore all guard
states/positions, gate collisions, loot, tools, carried object and pending route flags.
