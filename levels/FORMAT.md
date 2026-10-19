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
| `s` | Tenebri shade | patrols, chases, telegraphed strike, can block; dissolves on death |
| `^` | spikes | 1 damage and back to the last safe ground (not a full restart) |
| `h` / `H` | small potion (+2 health) / big potion (+1 max health) | |
| `k` | flame shrine | checkpoint + full heal |
| `E` | exit door | `UP` while standing in front completes the level |
| `1`–`9` | hint stone | shows `hintN` when Kael walks past |
| `t` | wall torch | warm flickering light + embers |
| `L` | hanging lantern | chain runs up to the ceiling above it |
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
