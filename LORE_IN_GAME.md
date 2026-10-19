# How the lore lives in the game

A guide for updating the Umbraverse lore and getting it into *Thief of Dawn*. Every place the game shows
story, names or world details is listed here, with how to change it. Most of it is plain text you can edit
directly; the rest is noted.

## How the game is put together

- **Engine:** Godot 4.7, 2D pixel art at 640×360, scaled up sharp and fullscreen.
- **Structure:** a title screen, then for each level: a **story card** (full-screen text), the **level**, and an
  **after-level card** that grants a **FATE Mark**. Five levels are planned, one per human city of the
  Umbraverse, ending at the Nexus of Creation. Level 1 is built; 2–5 are on the roadmap (`ROADMAP.md`).
- **The hero:** Kael, a young Valerin squire of the Order of the Shield.
- **The enemy:** Tenebri shades serving Morrow the Hollow, who stole the Lantern of Eterna.
- **The power system in play:** each FATE Mark (Traversa, Vitaria, Ascenda, Eterna, Enigma) unlocks an ability,
  so the six FATEs from the lore are what make Kael stronger: Traversa → wall jump, Vitaria → second wind
  (healing), Ascenda → double jump, Eterna → rewind time, Enigma → the ending. Bellara, the Conflict FATE, is
  Kael's own FATE (his sword).

## Where each piece of lore appears

| What | Where to change it | Format |
|---|---|---|
| The whole story (premise, hero, villain, five levels, characters) | `STORY.md` | Markdown. The design source: change it here first, then update the places below. |
| Story cards between levels (intro, after each level) | `story/cards.md` | `## intro`, `## after1` … `## after5`, then the text. Shown exactly as written. |
| Level names (shown on arrival) | `name:` line at the top of `levels/levelN.txt` | e.g. `name: The Vaults of Thalor` |
| Hint stones (short lines the player reads in the level) | `hint1:` … `hint9:` lines at the top of `levels/levelN.txt` | One line each. Also the right place for small lore snippets (inscriptions, notes). |
| FATE Mark names and the ability each grants | `src/game.gd` (`ABILITIES`) and the Mark list in `src/main.gd` | Code: ask Claude or Codex to change it. |
| Title of the game | `project.godot` (`config/name`) and `assets/ui/title.png` | The title image has the name painted in. |
| Pickup and checkpoint messages ("The flame remembers you") | `src/level.gd` (search for `toast`) | Code: one line each. |
| Character looks (Kael, shades, Vesh, Morrow) | `STORY.md` → *Characters (for art)*; art in `assets/sprites/` | Changing a look means regenerating art (PixelLab budget). |
| Level look and theme (library, mines, rooftops, walls, Nexus) | `theme:` in the level file picks `assets/tiles/levelN` and `assets/backgrounds/levelN.png` | Art. |

## The lore the game currently uses

- **The Umbraverse, the FATEs, the Law of Continuity** (from *Umbraverse – FATE*): the Lantern of Eterna keeps
  the Law of Continuity; Morrow wants to snuff it at dawn so the past can be rewritten.
- **The five human peoples and their cities** (from *Umbraverse – Humans*): Thalor (library vaults), Norra
  (mines), Dornis (rooftops and the Grand Festival), Valerion (walls; Captain Vesh), Sarath (Sarai, the healer).
- **The Tenebri** (from *Umbraverse – All Races*): shadow beings; enemies dissolve into shadow when beaten.
- **The Order of the Shield, the Council of Five, the Great War and the Peace Accord** (from the human timeline).
- **Invented for the game** (yours to keep, change or replace): Kael, Morrow the Hollow, Sarai of Sarath,
  Captain Vesh, the Lantern of Eterna, FATE Marks as abilities.

## Updating the lore

1. Edit your Google Drive lore as usual.
2. Update `STORY.md` so the game's design matches (or ask Claude to do it from the Drive docs).
3. Update the text the player sees: `story/cards.md` and the `name:` / `hint` lines in `levels/*.txt`.
4. Bigger changes (new characters, a different villain, new abilities) touch code or art: describe the change
   and let Claude or Codex carry it through.
