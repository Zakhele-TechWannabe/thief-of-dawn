# Roadmap

The foundation (level 1, Kael, the shade, combat, HUD, level format) is built. This is what comes next, in order.
Keep each step playable; take screenshots (`--shot`) and run the smoke test after each.

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

1. **Level 1 polish**: a scripted-input playthrough from `@` to `E` (proves it's completable), tune hint text,
   place 1–2 more shades on the upper galleries, add one optional secret (big potion) reachable only with a
   tricky ledge sequence.
2. **Level 2: The Deep Mines of Norra** (theme 2): new hazards (loose floor `L` that shakes then falls, mine-cart
   rails, dripping water), a new enemy (**Norran stone-hound** or a shade **archer** that must be closed on), wall-jump
   shafts. Needs: tiles/backgrounds already exist for theme 2.
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
check `art/ledger-godot.json`). Use `create-image-pro-flash` at 96×96 for characters (best results so far) and
`animate-with-text-v3` for animations; ~$0.03 per animation. Never call PixelLab any other way.
