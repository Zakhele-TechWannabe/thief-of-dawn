# Roadmap

Levels 1 and 2, Kael, shades and archers, combat, HUD, resettable loose floors, and scripted exit routes are built.
This is what comes next, in order.
Keep each step playable; take screenshots (`--shot`, when a display is accessible) and run `tests/run.sh` after each.

## Design pillars

1. **Weight and readability.** Prince of Persia's deliberate movement and ledge climbing; every enemy attack
   telegraphed (eyes flare, red glint), every hit landing with hit-stop, sparks and shake.
2. **Combat is a conversation.** Attack, dodge-roll through, or parry and punish. Enemies differ in *how*
   they must be answered, not just HP.
3. **Each FATE Mark is a new verb.** The Mark earned at the end of a level unlocks an ability, and the next level
   is built around it, so the game keeps changing as it goes (metroidvania-lite, linear levels).
4. **Dense, lit places.** No empty rooms: light sources, decor, foreground depth, a reason to look around.

## FATE Marks → abilities (in `Game.ABILITIES`; `Game.marks` holds what's earned)

| after level | Mark | ability | level built around it |
|---|---|---|---|
| 1 Vaults of Thalor | Traversa | **wall jump** (already in `player.gd`) | 2: mine shafts you climb wall-to-wall |
| 2 Deep Mines of Norra | Vitaria | **second wind**: hold Parry 1 s to heal 1 (3 charges, refilled at shrines) | 3: longer fights on the roofs |
| 3 Rooftops of Dornis | Ascenda | **double jump** (already in `player.gd`) | 4: the walls of Valerion, vertical |
| 4 Walls of Valerion | Eterna | **rewind**: on a fatal fall/hit, time rewinds 3 s once per shrine (Sands-of-Time nod) | 5 |
| 5 Nexus of Creation | Enigma | ending | — |

Grant the Mark on the level-complete card with a short reveal and a one-line explanation of the new verb.

## Next steps

1. **Level 1 polish (route complete)**: the committed `tests/routes/level1.seq` proves `@` to `E` using unchanged movement and geometry. Future polish: tune hint text,
   place 1–2 more shades on the upper galleries, add one optional secret (big potion) reachable only with a
   tricky ledge sequence.
2. **Level 2: The Deep Mines of Norra (complete)** (theme 2): three required wall-jump shafts, loose-floor
   haul bridge/catch tunnel, dripping water, ore, timber, five shades and three shade archers, two shrines,
   optional big-potion chimney. Built by `build_level2.py`; `tests/routes/level2.seq` proves the exit.
   Archers telegraph for 0.6 s, retreat and fire slow, parryable/reflected bolts; roll and jump also evade them.
   Direct level starts grant earlier marks. Flow: 1 → Traversa card → 2 → Vitaria card → title.
   Vitaria grants +1 max health now; implement its second-wind healing verb before level 3.
3. **Level 3: The Rooftops of Dornis** (theme 3): long running jumps, festival lanterns, wind gusts, more shades
   in groups of two.
4. **Level 4: The Walls of Valerion** (theme 4): slicer blades, timed portcullis runs, **Captain Vesh** boss
   (multi-phase duel: parry-heavy; art in `assets/sprites/vesh`, regenerate at 96 px if budget allows).
5. **Level 5: The Nexus of Creation** (theme 5): floating stone, everything combined, **Morrow** boss (teleports
   through shadow, summons shades at half health; art in `assets/sprites/morrow`).
6. **Sound**: footsteps, sword swings, clangs, parry ring, shade hiss, ambient loops per level, music cues.
7. **Save/continue**, settings (volume, fullscreen, rebinding shown in the controls bar), death counter / timer.

## Art budget

PixelLab via `tools/pixellab.py` with `PIXELLAB_LEDGER=ledger-godot.json` (hard cap $1.00 for this phase;
check `art/ledger-godot.json`; $0.71 spent, ~$0.29 left). Actors in use: `kael2` (96 px), `kael2_ledge`
(hang/climb registered on the ledge surface, see `art2/build.py build_ledge`), `shade2` (faces left, see
`meta.json` "faces"). Use `create-image-pro-flash` at 96×96 for characters (best results so far) and
`animate-with-text-v3` for animations; ~$0.03 per animation. Never call PixelLab any other way.

## Validation and export

`tests/run.sh` imports, smokes every `levels/level*.txt` for 1,800 frames, replays every route, and runs
focused mechanics integration checks, sequentially for low-memory machines. Every route must receive
`completed`; timeout, death, malformed sequences and missing files fail with position and exit code 1.
The new floor reset is connected to Kael's checkpoint respawn signal; no movement constants were changed.

**Export preset:** `levels/*.txt` and `story/*.md` must be in the non-resource export include filter.
Godot does not automatically include these text files merely because code reads them with FileAccess.

Current sandbox validation: no accessible X11/Wayland display, so `--shot` could not be used; rendering
and a human playtest of the new mine remain to be reviewed on a display-capable machine.
