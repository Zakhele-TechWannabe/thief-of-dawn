# Story direction

The agreed direction for *Thief of Dawn*. The full design is
[`STORY_AND_GAME_DESIGN_V1.md`](STORY_AND_GAME_DESIGN_V1.md); it stays unchanged as the source.
**Where the two differ, this document is the decision** (section 2 lists every override).

> **Guiding principle:** *Thief of Dawn* is the story of an ordinary criminal whose life matters to the people
> around him, even if it never matters to history.

> **North star:** At fifteen he breaks out of a cell to save himself. At thirty he breaks into one knowing he
> could run instead.

Nothing here is Umbraverse canon. Every new person, place and event stays **draft** in the lore sheet until
approved one by one. The Godot implementation is not to be changed for this direction yet.

---

## 1. Agreed

| Element | Decision |
|---|---|
| Creative direction | A long-form, multi-chapter game following one life: four chapters, Years 320, 324, 329 and 335. Not reduced to a single chapter for ease of shipping |
| First production milestone | **Chapter I, complete and self-contained**: a full narrative arc with its own ending, built and playtested before work on later chapters |
| Setting | Umbraverse, Era of Dawn. Later institutions (Grand Library, Order of the Shield, Grand Festival, Council of Five) don't exist yet |
| Protagonist | **Renn**, a Norran human from Slateford, 15 in Year 320, a genuine petty thief. Guilty, not framed |
| Family | Mother Ilen, father Boran, sister Nera. He loves them and still chooses himself |
| Stakes | Small and concrete: his escape forfeits the rope frame Ilen pledged. He knows, and runs anyway |
| Pursuer | **Hadrik**, a local watchman whose pride Renn hurt. Finite reach, not a villain. **Returns in Chapter IV** (3.1) |
| First non-humans | Verdans: Telu and the Greenwake community. A *local* relationship, not a species-wide one |
| Combat | Improvised and dirty alongside evasion. Trained guards are dangerous; two are frightening |
| Illiteracy | A real mechanic. UI and subtitles stay readable; in-world writing is what Renn can't use |
| Choices | Small named flags with **persistent** consequences in dialogue, routes, characters and epilogues. No separate campaigns, no branching chapters, no morality meter |
| Character arc | **No guaranteed redemption.** Growth is possible but not required: the player's choices decide how far it goes (3.3) |
| Crew | Five people who drift together without founding a guild. Roles and peoples follow from the story, not a checklist (3.2) |
| Rejected | A mysterious stolen artefact; a powerful antagonist; FATE Marks; prophecy; chosen-one destiny; a famous guild; an ethnicity-per-member crew |
| Existing Godot game | Kept as the technical prototype; Kael's story, Morrow, the Lantern, FATE Marks and shades are retired from this narrative |

## 2. Overrides to design V1

| V1 says | Decision now |
|---|---|
| "Target 15–20 hours of main story"; chapter targets of 3–4, 3–4, 5–6 and 4–6 hours; Chapter I stages "25–45 minutes each" | **Removed.** No playtime targets until there is playtest data |
| 22 authored stages; 6 / 5 / 6 / 5 per chapter | **Provisional.** The stage map is a content plan; counts change with playtesting |
| Hadrik: "His role ends in Chapter I; later appearances, if any, are local and conditional" | **He returns in Chapter IV** (3.1), so he survives Chapter I whatever Renn chooses |
| Deka is introduced in Chapter III (stage 12) | **Introduced in Chapter II** (3.2) |
| The crew: a Thalorian, a Norran, a Dornith and a Valerin alongside Renn | **Peoples and roles are open** and follow from where the crew operates and what the jobs need (3.2) |
| Chapter IV: "the central plot obliges him to find another route"; at the climax "Renn instead chooses a slower flooded service channel" | **A real choice.** The family-yard exit can be taken, with lasting consequences (3.3) |
| Ending: "The boy who always ran away has become a man who sometimes returns"; "the last button press takes him toward his companions" | **Depends on the player's choices.** The ending resolves in every version but doesn't assume he has changed (3.3) |
| Milestone 1 (the 20–30-minute vertical slice) as the first milestone | The vertical slice becomes the **first internal step** of the first milestone, Chapter I complete |

## 3. Decisions in detail

### 3.1 Hadrik returns in Chapter IV
Fifteen years after the escape, Hadrik is still in Slateford's watch and now **runs the holding cells** Renn must
break into to free Deka. He survives Chapter I in every version: if Renn leaves him at the bridge, Telu's
community gets him out, as V1 already allows.

`hadrik_helped` shapes Chapter IV:
- **Helped:** Hadrik recognizes Renn and owes him a debt he resents. He doesn't let Renn in, but there's a moment
  where he can look away once, or not. It's his choice; the player can't buy it.
- **Abandoned:** Hadrik remembers being left in the rain. He has rebuilt the cells around the boy who escaped
  them: the roof vent and drain from stage 2 are sealed, and the patrol is his own.

Both versions are playable; neither makes Hadrik a villain or a friend. *(Specifics draft.)*

### 3.2 The crew
- **Deka appears in Chapter II.** Proposal: he is the wheelwright whose workshop has the room above the road
  (stage 11). He rents it to Renn and Iri without asking questions, takes a cut of one job, and expects Renn to
  keep the promises he makes. By Chapter III he has joined; by Chapter IV the player knows why rescuing him
  matters. *(Proposal; open.)*
- **No checklist of peoples.** The crew is whoever this life brings together. They operate on the roads around
  Norra and its satellite settlements, so several are likely Norran; travellers and outsiders join because of a
  job, not to complete a set. Each member's people, and the order and reason they join, are open.
- Roles stay as V1 describes them (a reader and record-forger, someone who knows mechanisms, someone who works
  crowds, someone who can fight) unless the story needs otherwise.

### 3.3 No guaranteed redemption
- **Chapter IV, the family yard (stage 19).** Nera refuses to let him use the workshop. Renn can respect that or
  go behind her back. Neither is forced.
- **The climax (stage 22).** The family-yard exit opens. Taking it is faster and safer for the crew and exposes
  Nera's workshop: the family pays a second time, and `nera_boundary_respected` is false. Refusing it means the
  flooded service channel, a harder escape and a lost stash.
- **The ending resolves in every version.** Deka is out (or the attempt's cost is shown), the family scene
  happens, and Renn leaves. What the scene says depends on what he did: Nera may close the door; Ilen may still
  speak to him; the knot on the branch may be a signal to companions waiting for him, or a habit with no one to
  read it. He remains a thief in all of them.
- The same principle applies earlier: the wage money in Chapter III (`worker_wages_restored`), Telu's tool
  (`telu_tool_returned`), Hadrik at the bridge (`hadrik_helped`). Each is a credible trade-off, not a test with a
  right answer.

### 3.4 Choices persist without separate campaigns
- A small set of named flags (V1 §7.5), committed at chapter saves and never undone by a level death.
- A flag can change dialogue, a route, a secondary character's fate, how a returning place looks, or an epilogue.
- No flag creates a different chapter. Every player plays the same four chapters and the same stages; what
  differs is who remembers what, and how it lands.

## 4. Still open
- How his family's loss weighs on him across the years (it gives him something to lose; it doesn't make him a
  devoted son).
- The Greenwake Verdans: how much they know about humans; their local signs and language.
- Slateford's governance and law (who judges, how restitution and pledges work).
- The crew's peoples, order of joining, and which partnerships survive into Chapter IV.
- Names, the exact theft and penalty, dialogue, stage counts: free to change in writing and playtests.

## 5. Next step

The first production milestone is **Chapter I complete**. Its first internal step is the vertical slice from
V1 §12: the holding cell, a yard and a rooftop exit, young Renn, one guard with readable patrol, suspicion,
investigation and chase states, climb, slide, shove, throw, one theft interaction and a checkpoint.

**Not started.** The Godot implementation stays as it is until building begins.
