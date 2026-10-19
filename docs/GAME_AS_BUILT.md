# Thief of Dawn: the game as built

A complete picture of the game as it stands (levels 1 and 2 built), and of every piece of Umbraverse lore it
uses, so the lore can be updated with the game in mind. Companion to `LORE_IN_GAME.md` (where to edit each piece)
and `STORY.md` (the planned story for all five levels).

---

## 1. What kind of game it is

A 2D side-scrolling **action platformer** in pixel art. Movement borrows Prince of Persia's weight (deliberate
runs, ledge grabs, climbing up over edges); combat is quick and readable (a two-hit sword combo, a dodge roll, a
parry that sets up a critical counter). Each level ends with a **FATE Mark** that gives Kael a new ability, and the
next level is built around it.

- **Engine:** Godot 4.7. Pixel-perfect at 640×360, scaled up sharp; starts fullscreen (F11 toggles).
- **Length so far:** two levels, roughly 5–10 minutes each for a first play.
- **Run structure:** title screen → intro card → level 1 → card (Mark of Traversa) → level 2 → card (Mark of
  Vitaria) → back to the title ("to be continued").

## 2. The story frame (as shown to the player)

**Intro card:**
> The Grand Festival. Music in Dornis, lanterns over Thalor. Then the Library goes dark.
> Morrow the Hollow, keeper of the Council's records, walks out with the Lantern of Eterna, and with Sarai of
> Sarath. "At dawn," he says, "the past forgets itself."
> The vault door seals behind him. You are on the wrong side of it.

The premise behind it (from `STORY.md`): the **Lantern of Eterna**, a relic of the Legacy FATE kept in the
Grand Library of Thalor, holds the **Law of Continuity** in place. Morrow, a Tenebri shade who served the Council
of Five as keeper of records, means to snuff it at the **Nexus of Creation** at dawn so history can be rewritten:
the Great War never ends, the Peace Accord never happened, and the Tenebri, long blamed for the war, become its
victors. He takes **Sarai of Sarath**, the healer chosen to light the Lantern, as a hostage.

The player is **Kael**, a young **Valerin** squire of the **Order of the Shield**, who was on watch in the vaults
when the Lantern was taken.

## 3. How it plays

### Controls (always on screen)
Arrows/WASD move · Up/W/Space/Z jump (and climb) · X/J attack · C/L/Shift dodge-roll · V/K parry ·
Down+Jump drop through a plank · Up at a door to leave · Esc pause · F11 fullscreen/window. Gamepad supported.

### Movement
| | |
|---|---|
| Run | 165 px/s (≈10 tiles/s), quick start and stop |
| Jump | apex ≈ 5.5 tiles; hold for full height, release early for a hop |
| Running jump | clears ≈ 7 tiles |
| Ledge grab | jump toward a ledge and hold toward it; Kael hangs, Up/Jump climbs over, Down lets go. Climbs walls up to ≈ 8 tiles |
| Wall jump | (after the Mark of Traversa) jump while against a wall to kick off it |
| Planks | one-way: jump up through them, Down+Jump to drop |
| Falling | no fall damage |

### Combat
| | |
|---|---|
| Attack | two-hit combo: a fast thrust (1 damage) then a rising backhand slash (2 damage). Hits freeze the action for a few frames, shake the screen, and throw sparks |
| Dodge roll | a quick lunge forward; Kael cannot be hurt mid-roll |
| Parry | V raises the sword. In the first 0.2 s it **parries**: the attacker reels, and Kael's next hit within 1.2 s is a **critical** (×3 damage), usually a one-hit kill. Later it just **blocks** (no damage, pushed back) |
| Health | 5 red diamonds to start. Big potions add one permanently |
| Death | Kael falls; after a moment he returns at the last flame shrine with full health |
| Spikes / pits | lose 1 health and reappear on the last safe ground (no restart) |

### Enemies
| Enemy | Behaviour | How to beat it |
|---|---|---|
| **Tenebri shade** (melee) | Patrols, spots Kael, closes in. Before striking, its eyes flare and a red glint appears over its head (0.5 s). Sometimes blocks a hit from the front. 3 health | Parry the strike and counter, or hit it after it whiffs; roll through if caught. Dissolves into violet smoke when killed |
| **Shade archer** (level 2) | Keeps its distance, draws with a violet glint (0.6 s), fires a slow shadow bolt. 2 health, weak up close | Jump over the bolt, roll through it, or **parry it back** into the archer; then close in |

### Things in the levels
Flame shrines (checkpoint + full heal) · small potions (+2 health) · big potions (+1 max health, hidden) · hint
stones (a line of text as Kael walks past) · spikes · one-way planks · loose floors that shake then fall (level 2) ·
the exit door.

---

## 4. Level 1: The Vaults of Thalor

**Setting.** The sealed vaults under the **Grand Library of Thalor**: Thalorian stone, tall library shelves,
candlelight, cold light falling through high windows. Library background art, warm torches against blue shadow.

**Teaches:** running and jumping, the ledge grab, the first fight (and parry), the dodge roll.

**Route, left to right:**
1. **The sealed vault.** Kael starts behind the shut vault door. Low ceiling, bookshelves, a light shaft.
   *Hint stone 1:* "The vault is sealed. Find another way out." A low step teaches the jump.
2. **The first wall.** A 7-tile wall, too high to jump: the ledge grab. *Hint stone 2:* "Jump at a high ledge
   and hold toward it to grab on. UP to climb."
3. **The galleries.** A spike pit across a 6-tile gap (running jump). Wooden planks climb to an alcove with a
   potion. A hanging lantern over the gap.
4. **Whisper Hall.** A flame shrine, then the **first shade**. *Hint stone 3:* "A shade. Its eyes flare before it
   strikes: V to parry, then X to punish." Columns, lanterns, two light shafts, bookshelves.
5. **The crypt.** A drop down a shaft into a low, tight corridor with **two shades**, where jumping is cramped
   and the roll matters. *Hint stone 4:* "C to dodge-roll. Nothing can touch you mid-roll." A big potion waits at
   the end.
6. **The climbing chamber.** Three rising stone pillars to climb with ledge grabs, under a window.
7. **The scriptorium door.** A last shade guards the exit. *Hint stone 5:* "UP at the door to leave the vaults."

**Ends with:**
> FATE MARK OF TRAVERSA. You can now leap off walls: jump while sliding against one.
> The vault opens onto the old mine road. A Thalorian scholar's note, pinned to the stone: "He goes north,
> through Norra. Traversa guide you."

**Lore used in level 1**
| Lore | From | How it's used |
|---|---|---|
| Thalorians value learning; Thalor has grand libraries | *Humans* (Thalorians, Year 1500 Grand Library) | The setting: vaults under the Grand Library; bookshelves, scriptorium, the scholar's note |
| Thalorian architecture: stone and marble, symmetry, natural light | *Humans* | Pale stone masonry, columns, tall windows with light shafts |
| The Grand Festival (first held by Dorniths, Year 1600) | *Humans* | The night the theft happens |
| The Council of Five (Year 2000) | *Humans* | Morrow served it as keeper of records |
| Order of the Shield (Valerin peacekeepers, Year 1650) | *Humans* | Kael is its squire |
| Valerins: green skin, discipline, martial skill | *Humans* | Kael's look and his swordsmanship |
| Tenebri: shadow beings, can blend into darkness | *All Races* | The shades, and their dissolve-into-smoke deaths |
| Eterna (Legacy) and the Law of Continuity | *FATE* | The Lantern of Eterna and Morrow's plan |
| Traversa (Exploration), Law of Navigation | *FATE* | The first Mark; wall jump = finding a way where there was none |

## 5. Level 2: The Deep Mines of Norra

**Setting.** The mines of **Norra** in the Northern Mountains: rough rock, timber braces and props, hanging
lamps, dripping water, glints of ore in the walls. Mine-cavern background art, warmer and dimmer than Thalor.

**Built around:** the wall jump from Traversa's Mark. **New:** loose floors, the shade archer.

**Route** (a switchback that climbs, crosses, drops and climbs again):
1. **The lamp room** (bottom left). Kael enters from the mine road. *Hint stone 1:* "Traversa's Mark: hold toward
   a wall and press JUMP again to leap off it." *Hint stone 2:* "Climb the shaft: alternate walls and fresh jumps.
   UP also climbs a grabbed ledge."
2. **Shaft I.** 12 tiles straight up: only wall jumps get Kael out.
3. **The ore gallery.** A flame shrine, a shade, and the **first archer**. *Hint stone 3:* "Violet glint: an archer
   draws for a moment. Roll through, jump over, or face it and tap V to return its bolt."
   - *Secret:* a narrow side chimney, harder than the main shafts, leads to a **big potion**.
4. **Shaft II** up to the **high haul bridge.** The bridge is cracked slabs. *Hint stone 4:* "Cracked stone shakes,
   then falls. Keep moving! The lower gallery catches you." It collapses: Kael drops into the catch gallery below
   (with spikes to avoid) and goes on from there. A shade and an archer guard this stretch.
5. **The wet descent.** Planks break a long drop past dripping seams down to the second **flame shrine**.
   *Hint stone 5:* "The flame remembers. The last shaft leads toward Dornis; ore above hides another path."
6. **The deep sump.** A low tunnel with a shade and an archer.
7. **Shaft III** up into **the final timber gallery,** two more shades, and the exit toward Dornis.

**Ends with:**
> FATE MARK OF VITARIA. Survival leaves its mark. Your maximum health grows by one.
> Out of the mines, the festival still roars in Dornis. Nobody knows. Shadows move on the rooftops: Tenebri shades
> in Morrow's service.

**Lore used in level 2**
| Lore | From | How it's used |
|---|---|---|
| Norrans: hardy miners and engineers; Norra founded on rich mineral deposits in the Northern Mountains (Year 100) | *Humans* | The setting: deep mines, timber engineering, haul bridges, lifts |
| Norran architecture: practical, sturdy, wood and stone, reinforced | *Humans* | Timber braces and props everywhere, rough rock |
| Thalorians and Norrans as strong allies | *Humans* | The road from Thalor's vaults leads straight into Norra's mines |
| Vitaria (Survival): Law of Resilience | *FATE* | The second Mark, after the level that tests endurance most |
| Tenebri can hide in darkness | *All Races* | Shade archers striking from the dark tunnels |

---

## 6. Characters

| Character | Status | Description in game |
|---|---|---|
| **Kael** | invented | Young Valerin squire of the Order of the Shield: green skin, black ponytail, emerald eyes, dark-green tunic, ochre sash, curved short sword. FATE: Bellara (Conflict) |
| **Morrow the Hollow** | invented | Tenebri shade, the Council of Five's keeper of records; hollow white face, tattered scholar's robes; carries the Lantern. Seen only in story cards so far; final boss (level 5) |
| **Sarai of Sarath** | invented | Sarathian healer (maroon skin, black hair), chosen to light the Lantern; Morrow's hostage. Story cards only |
| **Captain Vesh** | invented | Valerin captain who betrays Valerion's gate (level 4 boss, not built yet) |
| **Tenebri shades** | from lore (*Tenebri*) | Hooded figures of living violet smoke with glowing eyes and curved blades |
| **Shade archers** | invented, from lore (*Tenebri*) | Shades that strike from range out of the dark |

## 7. FATE Marks and abilities

| Level | Mark | What it does now | Notes |
|---|---|---|---|
| 1 | **Traversa** (Exploration) | Wall jump | Working |
| 2 | **Vitaria** (Survival) | Card says "+1 maximum health" | **Not implemented yet**; the roadmap instead planned a healing ability ("second wind"). Needs a decision |
| 3 | **Ascenda** (Ambition) | Double jump | Coded, used from level 3 |
| 4 | **Eterna** (Legacy) | Planned: rewind time once per shrine | Not built |
| 5 | **Enigma** (Mystery) | Planned: the ending (the code currently has a placeholder "shadow dash") | Needs a decision |

**Bellara** (Conflict) is Kael's own FATE (his swordsmanship). It isn't a Mark.

## 8. Open lore questions (your call)

1. **Vitaria's gift:** more maximum health (what the card says), or a healing ability? Either fits the Law of
   Resilience. The card and the code have to match.
2. **Enigma's Mark:** an ending beat only, or a real power (e.g. stepping through shadow) for a final stretch?
3. **Morrow's motive:** currently "rewrite the Great War so the Tenebri become its victors." Does your lore have the
   Tenebri involved in the Great War? (The *Humans* doc describes the war as between the five human peoples.)
4. **Sarai of Sarath:** the *Humans* doc names **Sarath the Healer**, founder of Sarath. Should the hostage *be* a
   descendant of hers, or someone else?
5. **Kael's FATE, Bellara,** is stated in the design but never shown to the player. Should a card mention it?
6. **Names:** Kael, Morrow the Hollow, Sarai, Vesh and the Lantern of Eterna are invented for the game. Keep,
   rename, or replace with figures from your lore?
7. **Levels 3–5** follow the remaining human cities (Dornis rooftops, Valerion walls) and end at the **Nexus of
   Creation**. Any lore you want there (festival details for Dornis, Valerin religion's order and chaos, what the
   Nexus looks like)?
