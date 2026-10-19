# Level design and verification

Coordinates increase east and south. Letters identify rooms; dots are absent rooms. Maps show adjacency, not guaranteed safe openings. JSON is the authored source of truth.

## L1: The Vaults of Thalor

```text
A B H
D C .
E F .
. G .
```

- **A (0, 0) Sealed Stacks** — Walk, three-tile drop, two climbs and the sword-gate plate.
- **B (1, 0) Copyists’ Lift** — Upper crest, lower return gallery, running gap and standing-jump blade approach.
- **C (1, 1) Whisper Balcony** — Stepped descent; first shade after collecting the sword.
- **D (0, 1) Counterweight Well** — Return galleries and a west-hand shaft.
- **E (0, 2) Ink Cistern** — Optional healing descent and return climb.
- **F (1, 2) The Last Index** — Offset shelves, catch gallery and the final downshaft.
- **G (1, 3) The Mine Road** — Guarded exit approached from the upper east landing.
- **H (2, 0) The Squire’s Blade** — Gated side room: climb to the blade, then backtrack.

Checker route: **A → B → H → B → C → F → G**. 6 ledge climbs, 6 safe drops (including collapsing shelves), 3 vertical room transitions.

[Rendered room sheet](screens/level1-rooms.png).

## L2: The Deep Mines of Norra

```text
A B .
D C I
E F .
H G .
```

- **A (0, 0) Ore Weighhouse** — Split ore shelves, spikes, guard and remote entry plate.
- **B (1, 0) The Breaking Span** — Release plate on the loose bridge; collapse into the room below.
- **C (1, 1) Under the Bridge** — Safe bridge landing, guard and east potion detour.
- **D (0, 1) Blind Winch** — Spike ledge and west-hand descending well.
- **E (0, 2) Timber Teeth** — Timber steps above a spike pit and a shade.
- **F (1, 2) The Sinking Cage** — Split low bridge, catch gallery and a second collapse.
- **G (1, 3) Lantern Drain** — Upper landing, stacked drain galleries and shade.
- **H (0, 3) North Adit** — Climb the adit; door needs the bridge release.
- **I (2, 1) Vitaria’s Pocket** — Optional Vitaria big potion off the upper east balcony.

Checker route: **A → B → C → D → E → F → G → H**. 13 ledge climbs, 10 safe drops (including collapsing shelves), 3 vertical room transitions.

[Rendered room sheet](screens/level2-rooms.png).

## L3: The Rooftops of Dornis

```text
. A B I
. D C .
J E F .
. H G .
```

- **A (0, 0) Festival Eaves** — Split high roof requires a running jump; first rooftop guard.
- **B (1, 0) Bell Tower Gap** — Long bell-tower gap above the fatal void.
- **C (1, 1) Silk Awnings** — Awning shelves, guard and lower recovery gallery.
- **D (0, 1) The Empty Belfry** — Belfry switchback past spikes into the west shaft.
- **E (0, 2) Mosaic Roof** — Mosaic galleries over a spike pit, guarded eastern roof.
- **F (1, 2) Festival Chasm** — Five-column roof jump and a crumbling exit.
- **G (1, 3) High Procession** — Procession roofs with an exposed shade crossing.
- **H (0, 3) Valerion in Sight** — Final roof climb and the Valerion door.
- **I (2, 0) A Moonlit Detour** — Optional climb through the moonlit upper roof.
- **J (-1, 2) The Gold Weathercock** — Optional big potion on the western weathercock detour.

Checker route: **A → B → C → D → E → F → G → H**. 13 ledge climbs, 15 safe drops (including collapsing shelves), 3 vertical room transitions.

[Rendered room sheet](screens/level3-rooms.png).

## L4: The Walls of Valerion

```text
. A B I
. D C .
J E F .
. H G .
```

- **A (0, 0) Outer Machicolations** — Tall battlement crest, guard and exposed upper walkway.
- **B (1, 0) Blade Winch** — Slicer approach and a crumbling shaft landing.
- **C (1, 1) The Signal Descent** — Lower signal galleries, shade and split shelves.
- **D (0, 1) Iron Rain** — Slicer, spike shelf and west-hand shaft.
- **E (0, 2) Runner’s Oath** — Backtrack to the plate; begin the eight-second two-room run.
- **F (1, 2) The Closing Portcullis** — Cross the timed portcullis; arm the lower return gate.
- **G (1, 3) Captain’s Approach** — Slicer landing, guard and the permanent arena-door latch.
- **H (0, 3) Vesh’s Last Watch** — Vesh duel with upper galleries; combat-locked exit.
- **I (2, 0) Abandoned Barracks** — Optional barracks climb and healing ledges.
- **J (-1, 2) The Red Banner** — Optional west banner lookout with high return shelves.

Checker route: **A → B → C → D → E → F → G → H**. 14 ledge climbs, 16 safe drops (including collapsing shelves), 3 vertical room transitions.

[Rendered room sheet](screens/level4-rooms.png).

## L5: The Nexus of Creation

```text
. A B I
. D C .
J E F .
. H G .
```

- **A (0, 0) Sixfold Threshold** — Spike descent, shade and a 6.5-second remote gate.
- **B (1, 0) Continuity Fracture** — Loose bridge release arms the later interior gate.
- **C (1, 1) The Falling Archive** — Guarded archive shelves; an upper route into the next shaft.
- **D (0, 1) Conflict’s Teeth** — Optional spike-and-slicer switchback with healing shelves.
- **E (0, 2) Survival’s Thread** — Optional guarded survival crossing and west secret branch.
- **F (1, 2) Ambition Unmoored** — Climb the crest, descend left under the shelf, pass the interior gate, collapse the bridge.
- **G (1, 3) Legacy’s Shadow** — Slicer landing, guard and Lantern-door latch.
- **H (0, 3) Morrow at the Nexus** — Morrow and summoned shade below; climb two galleries to the Lantern door.
- **I (2, 0) The Unwritten Name** — Optional eastern climb through the unwritten platforms.
- **J (-1, 2) Enigma’s Memory** — Optional western big potion on the Enigma detour.

Checker route: **A → B → C → F → G → H**. 8 ledge climbs, 11 safe drops (including collapsing shelves), 3 vertical room transitions.

[Rendered room sheet](screens/level5-rooms.png).

## Verification limits

The support graph checks actual gravity, impulse, standing/running takeoff speeds, 12×46 body clearance, five-tile jump/grabs, at-most-six-tile direct drops, and nonfatal ballistic landings. Plate and sword ownership are route state. Boss nodes stand for defeating an opponent with the sword; the live game additionally requires every arena opponent to be dead.

Combat, cumulative potion/health management and slicer timing are not solved by the graph. Timed gates are treated as openable; a real scripted simulation separately proves the Valerion plate → climb → next-room gate run before its eight-second expiry. The Nexus timer has no complete scripted combat playthrough. These are validation limits, not a claim of five automated full-game playthroughs.

Every room sheet was rendered headlessly and visually inspected. Existing art is used as found; art generation and the excluded asset/tool paths were left untouched.
