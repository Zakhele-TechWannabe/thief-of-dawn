# Asset contract (engine ⇄ art)

The engine loads whatever exists under `assets/` and draws a procedural placeholder for anything missing, so
art and code can be built independently. All art is pixel art, nearest-neighbour scaled, no smoothing.

## Screen and grid

- Native resolution **480 × 270**, window scaled ×3 by default (1440 × 810).
- Tile size **16 × 16**. A room is **30 × 16 tiles** (480 × 256); the bottom 14 px are the HUD.
- Characters stand about **48 px (3 tiles)** tall.

## Character sprites

`assets/sprites/<actor>/<anim>/00.png, 01.png, …` with `assets/sprites/<actor>/meta.json`:

```json
{"frame_size": [64, 64], "anchor": [32, 60], "anims": {"run": {"fps": 12, "loop": true}, "death": {"fps": 8, "loop": false}}}
```

- Every frame is **64 × 64 RGBA**, transparent background, character **facing right** (the engine mirrors for left).
- **Anchor** (32, 60): the point between the feet on the ground. The engine places this point on the floor.
- Body roughly 44–50 px tall; consistent scale and palette across all animations of an actor.

| actor | animations (required first, then optional) |
|---|---|
| `kael` | idle, run, jump, fall, hang, climb, attack, block, hurt, death · optional: idle_sword, crouch, land |
| `shade` (Tenebri guard) | idle, walk, attack, block, hurt, death |
| `vesh` (captain, level 4 boss) | same set as shade (may be a recolour of shade) |
| `morrow` (final boss) | same set as shade, plus optional `cast` |

## Tiles

`assets/tiles/level<N>/` for N = 1..5, each file 16 × 16 RGBA:

- `solid.png`: the interior of floors and walls (repeats in a grid)
- `top.png`: a solid tile whose top edge is a walkable floor surface (used where air is directly above)
- `bg.png`: background wall, darker and lower contrast, repeats behind everything
- optional: `pillar.png` (decor, 16 × 48), `window.png`, `banner.png`, `edge_left.png`, `edge_right.png`

## Backgrounds

`assets/backgrounds/level<N>.png`, **480 × 256**, drawn behind the tile layer (the engine may darken it).
Optional. `bg.png` tiles are used only when the background image is absent, avoiding grid seams.

## Props (all optional; the engine draws procedural ones otherwise)

`assets/props/`: `torch_00.png…` (16 × 32 animation frames), `potion_small.png`, `potion_big.png` (16 × 16),
`sword.png` (32 × 16, pickup), `lantern.png` (16 × 32), `exit_door.png` (32 × 48), `gate.png` (16 × 48),
`spikes.png` (16 × 16), `loose_floor.png` (16 × 16), `plate.png` (16 × 8), `slicer.png` (16 × 48).

## UI

`assets/ui/title.png` (480 × 270 title-screen art, optional), `assets/ui/mark_<fate>.png` (32 × 32 icons for
traversa, vitaria, ascenda, eterna, enigma, optional).
