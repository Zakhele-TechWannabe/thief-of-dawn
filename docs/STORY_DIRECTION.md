# Story direction

The agreed direction for *Thief of Dawn*, what is still open, and review notes on the current design.
The full design is [`STORY_AND_GAME_DESIGN_V1.md`](STORY_AND_GAME_DESIGN_V1.md). Where the two differ, this
document records the decision.

> **Guiding principle:** *Thief of Dawn* is the story of an ordinary criminal whose life matters to the people
> around him, even if it never matters to history.

> **North star:** At fifteen he breaks out of a cell to save himself. At thirty he breaks into one knowing he
> could run instead.

Nothing here is Umbraverse canon. Every new person, place and event stays **draft** in the lore sheet until
approved one by one.

---

## 1. Agreed

| Element | Decision |
|---|---|
| Setting | Umbraverse, Era of Dawn, starting around Year 320. Later institutions (Grand Library, Order of the Shield, Grand Festival, Council of Five) don't exist yet |
| Protagonist | **Renn**, a Norran human, 15 in Year 320, a genuine petty thief. Guilty, not framed |
| Family | Yes: mother Ilen, father Boran, sister Nera. He loves them and still chooses himself |
| Backstory | Develop his childhood and the local history that shaped it (Slateford, Years 285–320), not fifty years of exposition |
| Initial conflict | Caught stealing, imprisoned, escapes with no destination |
| Motivation | Immediate survival and self-interest. No grand objective |
| Stakes | Small and concrete: his escape forfeits the rope frame his mother pledged. He knows, and runs anyway |
| Pursuer | Small and personal: **Hadrik**, a local watchman whose pride Renn hurt. Finite reach, not a villain |
| Rejected | A mysterious stolen artefact; a powerful antagonist; FATE Marks; prophecy; chosen-one destiny; a famous guild |
| First non-humans | Verdans (Telu, Greenwake). Unplanned from Renn's side; a *local* relationship, not a species-wide one |
| Combat | Improvised and dirty alongside evasion: shove, kick, throw, grab a weapon. Trained guards are dangerous |
| Illiteracy | A real mechanic. The UI stays readable; in-world writing is what Renn can't use |
| Choices | A handful of remembered flags that change dialogue, routes and epilogues. No branching chapters, no morality meter |
| First arc | Chapter I is a complete story with its own ending, built and playtested before anything else |
| Longer arc | Follow him across his life (four chapters, Years 320–335), developed progressively rather than scripted in full |
| Existing Godot game | Kept as the technical prototype. Kael's story, Morrow, the Lantern, FATE Marks and shades are retired from this narrative |

## 2. Open

- Exactly how his family's loss lands on him over time. It gives him something to lose; it doesn't guarantee he
  does the right thing. Does he go back, help, tell himself they're better off, or not care enough to risk it?
- Whether Hadrik reappears after Chapter I (see 3.3).
- How much the Greenwake Verdans know about humans, and their local signs and language.
- Slateford's governance and law (who judges, how restitution works).
- Which relationships survive the player's choices into the epilogue.
- Names, the exact theft, partner dialogue and stage counts per chapter: free to change in writing and playtests.

## 3. Review notes on design version 1

### 3.1 Strong: keep as written
- The pledged rope frame: a small, concrete cost he chooses to pay with someone else's livelihood.
- Telu and the water system, misread in Chapter I and understood in Chapter II: illiteracy and ignorance as plot,
  not description.
- Iri catching a written fraud by counting goods instead of reading.
- Chapter IV mirroring Chapter I (breaking into a cell instead of out), Nera refusing his money, the knot on the
  branch.
- The milestone plan: a 20–30 minute vertical slice first, then Chapter I complete, before any later chapter.

### 3.2 Scope and time estimates are inflated
- 15–20 hours across 22 stages assumes 25–45 minutes per stage. Platformer stages usually run 5–15 minutes, so
  the estimate either pads stages or overstates the game's length. Treat stage count as the plan and **measure**
  playtime in playtests instead of promising hours.
- Realistic Chapter I: six stages, roughly **1–1.5 hours** of play.
- Art: Renn at three ages plus Iri, Deka, Suli, Orven, Hadrik, Telu, the family and guards is several times the
  art bought so far. Budget it per chapter, not up front.

### 3.3 Hadrik's choice needs a payoff
In V1 his role ends in Chapter I and the bridge choice only reaches the epilogue. Proposal: in Chapter IV, Renn
breaks into **Slateford's** holding cells, so Hadrik should be there, fifteen years older and perhaps in charge.
Whether Renn pulled him off the bridge or left him shapes how the break-in goes. Consequence at an insignificant
scale, which is the premise. *(Open: needs the author's yes.)*

### 3.4 Chapter IV forces the virtuous choice
The design says "limited growth, not moral purification", but Chapter IV's plot obliges Renn to find another
route and then, at the climax, to refuse the family-yard exit. Every Chapter IV beat leans the same way, which
is a redemption arc in practice. Either make it a choice (the yard exit is possible, with `nera_boundary_respected`
recording what he did) or accept the redemption and say so. *(Open.)*

### 3.5 Deka arrives too late to carry the ending
Chapter IV depends on caring whether Deka gets out, but he is introduced in Chapter III alongside two others.
Introduce him in Chapter II (a job before Iri's, or the room above the road is his workshop).

## 4. Next step

**Milestone 1, the playable thief** (design §12): one holding cell, a short yard and a rooftop exit. New Renn
sprite (age 15), one guard with readable patrol, suspicion, investigation and chase states, climb, slide, shove
and throw, one theft interaction, checkpoint. Built on the current Godot engine.

**Passes when** a new player escapes without a wall of tutorial text, using more than one route, and knows Renn
is guilty.
