# Thief of Dawn art report

PixelLab requests used only `tools/pixellab.py` (`call`, `poll`, `get`, `spent`); no direct API client. No engine, data, tests, or README changes. No commits.

## Cost and provenance

Total measured spend: **$0.91544**. The $1 wrapper hard cap was used throughout. Initial requests and planned retries used a $0.90 planning ceiling; a late shade-hurt repair used the explicitly reserved $0.10 fix allowance. A delayed charge for the DNS-interrupted Morrow job arrived during that repair; both are included in the real total.

The wrapper can record zero for a synchronous image when its balance charge arrives just after its final balance read. The real final spend includes these delayed charges. Ledger cost below is the wrapper measurement, with response usage separately shown for reconciliation; response usage is not substituted for real total spend.

| Item | Endpoint | Ledger cost USD | Response usage | Prompt |
|---|---|---:|---:|---|
| kael | create-image-pixflux | 0.00000 | $0.00660 | Full body side profile facing RIGHT, lean adult green-skinned Valerin youth, black hair tied back, emerald eye, dark green tunic, brown leather bracers boots and ochre sash. Empty hands, agile swordsman standing idle. Prince of Persia cinematic pixel art, realistic slender proportions, 48 pixels tall centered on 64 canvas, crisp pixels, transparent background, no shadow. |
| kael_run | animate-with-text-v3 | 0.01989 | $0.01989 | Run in place toward the right, full side profile, athletic realistic stride, same green skin black ponytail dark green tunic brown boots and ochre sash, empty hands, fixed camera and consistent scale. |
| kael_idle | animate-with-text | 0.00000 | $0.01623 | Lean green-skinned young swordsman, black ponytail, dark green tunic, brown leather boots bracers, ochre sash, empty hands. Preserve reference precisely. / Subtle breathing idle cycle, standing in place, right facing side profile. |
| kael_jump | animate-with-text | 0.00000 | $0.01626 | Lean green-skinned youth, black ponytail, dark green tunic, ochre sash, brown leather boots and bracers. / Jump takeoff then tucked knees ascending, arms raised, empty hands. Side profile facing RIGHT throughout, fixed camera and scale. |
| kael_fall | animate-with-text | 0.00000 | $0.01788 | Lean green-skinned youth, black ponytail, dark green tunic, ochre sash, brown leather boots and bracers. / Falling downward feet below hips and arms reaching forward, empty hands. Side profile facing RIGHT throughout, fixed camera and scale. |
| kael_hang | animate-with-text | 0.00000 | $0.01561 | Lean green-skinned youth, black ponytail, dark green tunic, ochre sash, brown leather boots and bracers. / Hanging from a ledge above with both hands extended overhead, legs dangling below. Side profile facing RIGHT throughout, fixed camera and scale. |
| kael_climb | animate-with-text | 0.00000 | $0.01440 | Lean green-skinned youth, black ponytail, dark green tunic, ochre sash, brown leather boots and bracers. / Pulling up onto a ledge with arms overhead, lift one knee onto the ledge then stand. Side profile facing RIGHT throughout, fixed camera and scale. |
| kael_attack | animate-with-text | 0.01440 | $0.01251 | Lean green-skinned youth, black ponytail, dark green tunic, ochre sash, brown leather boots and bracers. / Draw a curved short sword and slash forward to the right, clear anticipation strike recovery. Side profile facing RIGHT throughout, fixed camera and scale. |
| kael_block | animate-with-text | 0.00000 | $0.01539 | Lean green-skinned youth, black ponytail, dark green tunic, ochre sash, brown leather boots and bracers. / Raise curved short sword in front to parry an incoming attack from the right. Side profile facing RIGHT throughout, fixed camera and scale. |
| kael_hurt | animate-with-text | 0.01539 | $0.01601 | Lean green-skinned youth, black ponytail, dark green tunic, ochre sash, brown leather boots and bracers. / Recoil from a blow, stagger backward, recover footing. Side profile facing RIGHT throughout, fixed camera and scale. |
| kael_death | animate-with-text | 0.01261 | $0.01261 | Lean green-skinned youth, black ponytail, dark green tunic, ochre sash, brown leather boots and bracers. / Collapse to the ground and lie motionless, body extends horizontally. Side profile facing RIGHT throughout, fixed camera and scale. |
| shade | create-image-pixflux | 0.00000 | $0.00674 | Full body spectral Tenebri shade guard, dark violet humanoid with wispy edges and pale glowing eyes, narrow hooded head, dark purple layered leather tunic, curved silver blade in right hand, tall lean realistic proportions. Side profile facing RIGHT, cinematic Prince of Persia pixel art, 48 pixel tall body centered in 64 pixel canvas. Transparent background, no ground shadow. |
| shade_idle | animate-with-text | 0.00000 | $0.01581 | Spectral dark violet Tenebri shade humanoid guard, pale glowing eyes, purple tunic, curved silver blade. Preserve reference character precisely. / Subtle breathing guard stance idle loop holding curved blade. Side profile facing RIGHT throughout, fixed camera and scale. |
| shade_walk | animate-with-text | 0.00000 | $0.01622 | Spectral dark violet Tenebri shade humanoid guard, pale glowing eyes, purple tunic, curved silver blade. Preserve reference character precisely. / Walk in place to the right, steady full stride, curved blade held. Side profile facing RIGHT throughout, fixed camera and scale. |
| shade_attack | animate-with-text | 0.00000 | $0.01254 | Spectral dark violet Tenebri shade humanoid guard, pale glowing eyes, purple tunic, curved silver blade. Preserve reference character precisely. / Slash curved blade toward the right with anticipation strike recovery. Side profile facing RIGHT throughout, fixed camera and scale. |
| shade_block | animate-with-text | 0.00000 | $0.01581 | Spectral dark violet Tenebri shade humanoid guard, pale glowing eyes, purple tunic, curved silver blade. Preserve reference character precisely. / Raise curved sword to block and parry from the right. Side profile facing RIGHT throughout, fixed camera and scale. |
| shade_hurt | animate-with-text | 0.01581 | $0.01539 | Spectral dark violet Tenebri shade humanoid guard, pale glowing eyes, purple tunic, curved silver blade. Preserve reference character precisely. / Stagger backwards from being struck then recover. Side profile facing RIGHT throughout, fixed camera and scale. |
| shade_death | animate-with-text | 0.00000 | $0.01820 | Spectral dark violet Tenebri shade humanoid guard, pale glowing eyes, purple tunic, curved silver blade. Preserve reference character precisely. / Collapse to the floor and dissolve, final pose lying horizontally. Side profile facing RIGHT throughout, fixed camera and scale. |
| kael_jump_retry | animate-with-text-v3 | 0.01984 | $0.01984 | Small athletic vertical jump in place, SIDE PROFILE FACING RIGHT at all times. Bend knees, push off, lift knees slightly, extend legs to land. Remain upright; NO flips, NO spins, NO somersaults. Empty hands. Preserve the original dark green tunic, black ponytail and green skin. |
| kael_block_retry | animate-with-text-v3 | 0.02182 | $0.02182 | Standing side profile facing RIGHT, draw a short curved sword in front of chest, lift it slightly to parry a strike from the right and return to guard. Feet remain planted. Camera stays at side; preserve exact original green tunic, green skin, black ponytail and brown boots. |
| kael_hurt_retry | animate-with-text-v3 | 0.02133 | $0.02133 | Standing SIDE PROFILE facing RIGHT, flinch as chest is struck, head and shoulders recoil slightly to the left, then return to original pose. Keep original dark green tunic fully covering torso, green skin and black ponytail. No costume changes. |
| kael_attack_retry | animate-with-text-v3 | 0.02254 | $0.02254 | Draw a small curved short sword and slash forward toward RIGHT, then return to guard. Full SIDE PROFILE FACING RIGHT the whole time. Keep exactly the original dark green tunic, brown bracers, black ponytail and green skin. No giant white swoosh effects, no camera movement. |
| kael_death_retry | animate-with-text-v3 | 0.02473 | $0.02473 | This same green-skinned swordsman in his dark green tunic staggers, knees buckle, collapses SIDEWAYS onto the ground, ends lying horizontally motionless. Keep exact original outfit and scale. SIDE PROFILE FACING RIGHT, no recovery to standing, no camera rotation. |
| shade_death_retry | animate-with-text-v3 | 0.02379 | $0.02379 | Side profile facing RIGHT. This same hooded violet guard staggers, bends knees, collapses sideways to the ground and lies flat motionless. Sword drops beside body. Preserve original narrow humanoid proportions and outfit. No giant blade trails, no rectangular effects, no zoom. Fixed camera and scale. |
| tiles1 | create-tileset-sidescroller | 0.00000 | {"type": "generations", "generations": 3.0} | Thalor library vaults, carved ivory marble blocks, ink-blue seams, cinematic fantasy pixel art platform masonry, solid readable structure / thin worn flat walkable stone ledge |
| tiles2 | create-tileset-sidescroller | 0.00000 | {"type": "generations", "generations": 3.0} | Norra deep mines, rough dark slate stone, brown timber braces, sparse copper ore, cinematic fantasy pixel art platform masonry, solid readable structure / thin worn flat walkable stone ledge |
| tiles3 | create-tileset-sidescroller | 0.00000 | {"type": "generations", "generations": 3.0} | Dornis rooftops, weathered terracotta bricks, blue gold mosaic trim, cinematic fantasy pixel art platform masonry, solid readable structure / thin worn flat walkable stone ledge |
| tiles4 | create-tileset-sidescroller | 0.00000 | {"type": "generations", "generations": 3.0} | Valerion fortress, grey stone masonry, iron rivets, cinematic fantasy pixel art platform masonry, solid readable structure / thin worn flat walkable stone ledge |
| tiles5 | create-tileset-sidescroller | 0.00000 | {"type": "generations", "generations": 3.0} | Nexus of Creation, ancient dark floating stone, violet runic seams, cinematic fantasy pixel art platform masonry, solid readable structure / thin worn flat walkable stone ledge |
| background1 | create-image-pixflux-background | 0.00649 | $0.00649 | Wide side-view background for cinematic pixel art platformer, Thalor library vaults: candlelit arches, shelves of ancient books, library vault, deep ink-blue shadows. Low contrast, dark subdued palette, distant architecture only, no foreground platforms, no characters, no text. Actors must read clearly on top. |
| background2 | create-image-pixflux-background | 0.00666 | $0.00666 | Wide side-view background for cinematic pixel art platformer, Norra deep mines: subterranean mine galleries, timber props, lanterns and tiny copper ore glints. Low contrast, dark subdued palette, distant architecture only, no foreground platforms, no characters, no text. Actors must read clearly on top. |
| background3 | create-image-pixflux-background | 0.00724 | $0.00724 | Wide side-view background for cinematic pixel art platformer, Dornis rooftops: festival city rooftops at night, tiny distant paper lanterns, mosaic walls and awnings. Low contrast, dark subdued palette, distant architecture only, no foreground platforms, no characters, no text. Actors must read clearly on top. |
| background4 | create-image-pixflux-background | 0.00598 | $0.00598 | Wide side-view background for cinematic pixel art platformer, Valerion fortress: grey fortress battlements, iron gates, hanging muted crimson banners beneath a night sky. Low contrast, dark subdued palette, distant architecture only, no foreground platforms, no characters, no text. Actors must read clearly on top. |
| background5 | create-image-pixflux-background | 0.00696 | $0.00696 | Wide side-view background for cinematic pixel art platformer, Nexus of Creation: floating ancient stones in swirling mist and void-violet light, distant dawn glow. Low contrast, dark subdued palette, distant architecture only, no foreground platforms, no characters, no text. Actors must read clearly on top. |
| prop_torch | create-image-pixflux | 0.00000 | $0.00654 | medieval wall torch, iron bracket and orange flame, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_potion_small | create-image-pixflux | 0.00000 | $0.00706 | tiny red healing potion glass bottle, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_potion_big | create-image-pixflux | 0.00000 | $0.00646 | large ornate golden green potion bottle, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_sword | create-image-pixflux | 0.00000 | $0.00707 | curved short silver sword lying horizontally, gold hilt on left, tip pointing right, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_lantern | create-image-pixflux | 0.00000 | $0.01367 | Lantern of Eterna, ornate gold lantern containing warm white golden flame, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_exit_door | create-image-pixflux | 0.02108 | $0.00741 | ancient tall arched open stone doorway, black interior, gold rune above, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_gate | create-image-pixflux | 0.00000 | $0.00627 | vertical iron portcullis gate with pointed bars, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_spikes | create-image-pixflux | 0.00000 | $0.00674 | three sharp upward steel floor spikes, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_loose_floor | create-image-pixflux | 0.00674 | $0.00773 | cracked fragile stone floor tile, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_plate | create-image-pixflux | 0.00644 | $0.00644 | low stone pressure plate with golden button, horizontal side view, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| prop_slicer | create-image-pixflux | 0.00000 | $0.00671 | vertical mechanical trap, two sharp opposing curved silver blades on iron frame, side view fantasy pixel art game prop, centered full object, transparent background, crisp pixel edges, no text |
| shade_attack_retry | animate-with-text-v3 | 0.02135 | $0.02135 | This exact hooded violet guard remains in full side profile FACING RIGHT and thrusts his curved short sword forward toward the right, then returns to guard. Preserve original narrow humanoid body, hood and pale mask. NO turning away, no spinning, no giant swoosh effects. Fixed camera and scale. |
| vesh | create-image-pixflux | 0.00000 | $0.00612 | Captain Vesh, armoured Valerin traitor captain with GREEN SKIN, grey steel breastplate helmet and greaves, long red cloak behind him, curved short sword held forward. Tall lean realistic adult human proportions. Full body SIDE PROFILE FACING RIGHT. Cinematic fantasy platformer pixel art. About 48 pixels tall centered in 64 pixel canvas, transparent background, no ground shadow. |
| vesh_walk | animate-with-text | 0.00000 | $0.01361 | Captain Vesh, armoured Valerin traitor captain with GREEN SKIN, grey steel breastplate helmet and greaves, long red cloak behind him, curved short sword held forward. Tall lean realistic adult human proportions. Preserve reference design and colours. / walking in place toward right, full side profile facing right, fixed camera and scale |
| vesh_attack | animate-with-text | 0.01294 | $0.01294 | Captain Vesh, armoured Valerin traitor captain with GREEN SKIN, grey steel breastplate helmet and greaves, long red cloak behind him, curved short sword held forward. Tall lean realistic adult human proportions. Preserve reference design and colours. / short sword thrust forward toward right, full side profile facing right, fixed camera and scale |
| vesh_block | animate-with-text | 0.01265 | $0.01265 | Captain Vesh, armoured Valerin traitor captain with GREEN SKIN, grey steel breastplate helmet and greaves, long red cloak behind him, curved short sword held forward. Tall lean realistic adult human proportions. Preserve reference design and colours. / holding sword upright to parry an attack from right, full side profile facing right, fixed camera and scale |
| vesh_hurt | animate-with-text | 0.00000 | $0.01535 | Captain Vesh, armoured Valerin traitor captain with GREEN SKIN, grey steel breastplate helmet and greaves, long red cloak behind him, curved short sword held forward. Tall lean realistic adult human proportions. Preserve reference design and colours. / brief recoil backwards from a hit, keep facing right, full side profile facing right, fixed camera and scale |
| vesh_death | animate-with-text-v3 | 0.04306 | $0.02771 | Side profile facing RIGHT. Captain Vesh, armoured Valerin traitor captain with GREEN SKIN, grey steel breastplate helmet and greaves, long red cloak behind him, curved short sword held forward. Tall lean realistic adult human proportions. Stagger, knees buckle, fall sideways, settle flat on the ground and remain completely motionless for the final two frames. Preserve exact reference design, fixed camera and scale, no recovery. |
| morrow | create-image-pixflux | 0.00000 | $0.00668 | Morrow the Hollow, tall slender spectral Tenebri scholar in long tattered dark violet robes, hollow white mask-like face with black eye sockets, hood, carries small glowing gold Lantern of Eterna in forward hand. No sword. Tall realistic humanoid proportions, mysterious silhouette. Full body SIDE PROFILE FACING RIGHT. Cinematic fantasy platformer pixel art. About 48 pixels tall centered in 64 pixel canvas, transparent background, no ground shadow. |
| morrow_walk | animate-with-text | 0.00668 | $0.01435 | Morrow the Hollow, tall slender spectral Tenebri scholar in long tattered dark violet robes, hollow white mask-like face with black eye sockets, hood, carries small glowing gold Lantern of Eterna in forward hand. No sword. Tall realistic humanoid proportions, mysterious silhouette. Preserve reference design and colours. / walking in place toward right, full side profile facing right, fixed camera and scale |
| morrow_attack | animate-with-text | 0.00000 | $0.01582 | Morrow the Hollow, tall slender spectral Tenebri scholar in long tattered dark violet robes, hollow white mask-like face with black eye sockets, hood, carries small glowing gold Lantern of Eterna in forward hand. No sword. Tall realistic humanoid proportions, mysterious silhouette. Preserve reference design and colours. / raising glowing lantern to cast a shadow spell toward right, full side profile facing right, fixed camera and scale |
| morrow_block | animate-with-text | 0.00000 | $0.01432 | Morrow the Hollow, tall slender spectral Tenebri scholar in long tattered dark violet robes, hollow white mask-like face with black eye sockets, hood, carries small glowing gold Lantern of Eterna in forward hand. No sword. Tall realistic humanoid proportions, mysterious silhouette. Preserve reference design and colours. / raising free hand in front to conjure a violet ward, full side profile facing right, fixed camera and scale |
| morrow_hurt | animate-with-text | 0.01432 | $0.01564 | Morrow the Hollow, tall slender spectral Tenebri scholar in long tattered dark violet robes, hollow white mask-like face with black eye sockets, hood, carries small glowing gold Lantern of Eterna in forward hand. No sword. Tall realistic humanoid proportions, mysterious silhouette. Preserve reference design and colours. / brief recoil backwards from a hit, keep facing right, full side profile facing right, fixed camera and scale |
| morrow_death | animate-with-text-v3 | 0.02893 | $0.02893 | Side profile facing RIGHT. Morrow the Hollow, tall slender spectral Tenebri scholar in long tattered dark violet robes, hollow white mask-like face with black eye sockets, hood, carries small glowing gold Lantern of Eterna in forward hand. No sword. Tall realistic humanoid proportions, mysterious silhouette. Stagger, knees buckle, fall sideways, settle flat on the ground and remain completely motionless for the final two frames. Preserve exact reference design, fixed camera and scale, no recovery. |
| mark_traversa | create-image-pixflux | 0.00000 | $0.00641 | Sacred FATE mark icon: compass with path and star, teal. Ornate readable fantasy pixel art emblem, centered, transparent background, no lettering |
| mark_vitaria | create-image-pixflux | 0.00000 | $0.00647 | Sacred FATE mark icon: sprouting leaf within protective circle, green. Ornate readable fantasy pixel art emblem, centered, transparent background, no lettering |
| mark_ascenda | create-image-pixflux | 0.00000 | $0.00717 | Sacred FATE mark icon: upward arrow over mountain peak, amber. Ornate readable fantasy pixel art emblem, centered, transparent background, no lettering |
| mark_eterna | create-image-pixflux | 0.00000 | $0.00693 | Sacred FATE mark icon: eternal golden flame in ring, gold. Ornate readable fantasy pixel art emblem, centered, transparent background, no lettering |
| mark_enigma | create-image-pixflux | 0.00693 | $0.00994 | Sacred FATE mark icon: crescent moon around a mysterious violet eye, violet. Ornate readable fantasy pixel art emblem, centered, transparent background, no lettering |
| title | create-image-pixflux-background | 0.00667 | $0.00667 | Cinematic pixel art fantasy title screen illustration, lean green-skinned black ponytailed swordsman in dark green tunic seen in silhouette on left stone battlement, gold magical lantern on right, ancient library arches and floating violet ruins, starry night giving way to a thin golden dawn, dramatic dark blue and violet palette with warm gold accents. Open dark sky in upper center for title lettering, no text. |
| vesh_attack_retry | animate-with-text-v3 | 0.02009 | $0.02009 | Full SIDE PROFILE FACING RIGHT. Thrust the short curved sword toward the right, pull it back to guard. Preserve exact original green skin, steel armour, red cloak. No turns, no spins, no camera movement, no ground or pedestal. |
| vesh_block_retry | animate-with-text-v3 | 0.03112 | $0.03112 | Full SIDE PROFILE FACING RIGHT. Lift the short sword in front of the face to parry a strike from the right, hold the parry. Keep green skin, steel armour and red cloak exactly. No turns, no backdrop, no ground or pedestal. |
| morrow_walk_retry | animate-with-text-v3 | 0.02362 | $0.02362 | This exact masked violet-robed scholar glides in place toward RIGHT, subtle robe and arm movement. Full SIDE PROFILE FACING RIGHT throughout, hold the small gold Lantern in forward hand. Preserve the white mask and long robe. Transparent empty background, no camera movement, no turns. |
| morrow_attack_retry | animate-with-text-v3 | 0.02141 | $0.02141 | Full SIDE PROFILE FACING RIGHT. This exact pale-masked violet scholar raises the small golden Lantern toward the right, extends free hand forward and casts a small violet shadow spell, then lowers the Lantern. Preserve original robes and silhouette. No swords, no backdrop, no turns. |
| shade_hurt_retry | animate-with-text-v3 | 0.05654 | $0.01987 | The EXACT same narrow hooded violet guard FLINCHES slightly backwards from a hit coming from the RIGHT, then regains his footing. Keep SIDE PROFILE FACING RIGHT throughout. Preserve the original hood, pale face, dark violet outfit and small curved sword. Sword remains still. No sword trails, no white rectangles, no bright effects, no new objects. Fixed camera and scale, transparent background. |

## Processing and approximations

- Frames: 64×64 RGBA, binary alpha, right-facing references, feet anchor (32,60), scale derived from each actor’s base reference with a documented correction for undersized legacy ledge poses; nearest-neighbour only. The v3 reference frame is omitted from the run loop.
- Every animation derives from that actor’s one reference image; Kael is unarmed in locomotion and uses the sword in combat clips.
- Vesh uses a dedicated PixelLab grey-steel, green-skinned, red-cloaked reference and reference-conditioned animations.
- Morrow uses a dedicated PixelLab tattered violet scholar reference with pale mask and Lantern, plus reference-conditioned animations. Attack is a Lantern spell, not a sword slash.
- Props are generated at twice the required dimensions to satisfy the API minimum canvas area, then reduced with nearest-neighbour scaling.
- Torch has three local flame variants derived from one PixelLab prop, rather than three separately generated frames.
- Backgrounds generated at 240×128 and doubled to 480×256; title at 240×136 doubled and vertically cropped to 480×270 with local lettering.
- Tiles are cut from PixelLab sidescroller sheets; bg is a darkened solid tile, pillar and window are local compositions of generated masonry.
- No optional Sarai portrait, Kael idle_sword/crouch/land, or Morrow cast. The engine can use its documented placeholders for absent optional assets.

## Contract and rebuild

All generated art outputs are under `assets/` and `art/`. The explicitly requested source entry point is `tools/art_build.py`; its implementation and build recipes live in `art/`. Rebuild offline with `python -B tools/art_build.py`. Pillow 13.0.0 and its license metadata are archived under git-ignored `art/raw/python_deps/` for this Python 3.12/Linux environment; the build automatically uses that local copy if Pillow is not installed. No network is required.

Raw responses and requests are retained in git-ignored `art/raw/`. API keys were never copied into them. `art/contact_sheet.png` includes every output image, grouped into labelled character strips and rendered ×2. Complete source Wang atlases and rejected attempts appear after the delivered assets.

## Balance reconciliation

```json
{
  "spent_usd": 0.91544187855721,
  "completed_response_usage_usd": 0.8787675274080701,
  "unrecovered_job_charge_inferred_usd": 0.03667435114913997,
  "inferred_job": "morrow_death_retry",
  "note": "DNS interrupted the call/poll response; initial job UUID was not retained by the wrapper. The late charge appeared during the shade-hurt retry and is included in that ledger balance change. No additional Morrow POST was submitted.",
  "successful_calls": 69
}
```

## Review selections

Generated clips can change proportions or camera direction. Rejected attempts remain under art/raw and appear as labelled rejected strips on the contact sheet.
- Idle uses original reference as a stable single pose because the legacy breathing clip changes his clothing.
- Hang uses overhead ledge-gripping climb frame 1; generated hanging frames were pale and inconsistent.
- Shade idle uses original reference; generated breathing clip exaggerates the blade.
- Shade block uses the final two right-profile frames; oversized opening blade effects rejected.
- Final fall uses the descending airborne pose from the accepted v3 jump, maintaining the original character identity.
- Run omits the v3 reference frame so the four moving frames form the loop.
- Shade death is absent after two unsuccessful attempts; engine must use its procedural placeholder. Kael death ends in a seated collapse rather than fully flat.
- Shade walk frames 1 and 2 originally face left and are mirrored locally to face right.
- Ground fixtures (spikes, pressure plate and loose floor) are locally cropped and aligned to the bottom edge of their required canvases.
- Sword pickup is a straight silver blade; combat sprites use the short curved blade interpretation.
- Final Kael run/jump/attack/block/hurt/death and shade attack use v3 clips from their original base references; accepted retries supersede rejected legacy clips.
- Vesh source contains a brown ground pedestal despite the prompt. The offline build removes wide brown ground rows below his boots; the walk uses right-profile frames 1–3.
- Vesh hurt retains the final right-profile pose as a static recoil state; frontal frames rejected.
- Legacy Kael hang/climb frames were drawn with undersized anatomy; a fixed 1.18 scale correction restores a body near the standing reference size while keeping the same foot anchor.
- Morrow hurt retains the first two transparent right-profile recoil poses; later frontal/background frames are discarded.
- Morrow block uses the first two consistent Lantern-holding guard poses as a held defensive state; a separate ward effect was not generated.
- Gate, spikes and slicer metal is brightened locally for readability against the dark level backgrounds.
- Rejected kael_jump: Legacy clip shrinks and somersaults; requires one improved retry.
- Rejected kael_block: Legacy clip faces away and oversized sword effects.
- Rejected kael_hurt: Legacy clip changes tunic to a pale shirt.
- Rejected shade_death: Legacy clip consists of giant rectangular blade effects.
- Rejected kael_idle: Breathing clip changes clothing; base pose used.
- Rejected kael_hang: Changes palette and proportions; climb overhead pose used.
- Rejected shade_idle: Blade trail exaggerated; base pose used.
- Rejected kael_attack: Legacy clip changes clothing and enlarges blade; v3 retry for consistency.
- Rejected kael_death: Legacy collapse changes outfit and returns to standing later; v3 retry.
- Rejected kael_fall: Frontal frames and clothing drift; using accepted v3 jump descending pose.
- Rejected shade_attack: Legacy clip turns away from camera and adds huge sword trails; one v3 retry queued.
- Rejected shade_block: Opening blade effects oversized; selected closing two right-profile frames only.
- Rejected shade_hurt: Legacy hurt includes rectangular white sword effects and altered head; one reserved-budget v3 retry queued.
- Rejected shade_death_retry: Second attempt only bends into a guard crouch; no death. No further retry; engine placeholder retained.
- Rejected vesh_walk: Opening frame is frontal; use three right-profile frames and remove ground pedestal locally.
- Rejected vesh_attack: Legacy attack faces away; needs one retry.
- Rejected vesh_block: Opaque background and frontal poses; needs one retry.
- Rejected vesh_hurt: Opening frames face front; last right-profile recoil pose retained as a single frame.
- Rejected morrow_walk: Legacy clip paints an opaque grey background and changes design; one v3 retry queued.
- Rejected morrow_attack: Legacy clip paints an opaque grey background and changes design; one v3 retry queued.
- Rejected morrow_block: Later frontal poses discarded; retain first two right-profile Lantern guard frames.
- Rejected morrow_hurt: Final two poses are frontal with opaque background; retain first two transparent right-profile poses.
- Rejected morrow_death: Eight-frame collapse only leans forward; one dissolve retry with an explicit empty end frame queued, budget permitting.
- Rejected morrow_death_retry: Retry failed: <urlopen error [Errno -3] Temporary failure in name resolution>

## API failures

```json
[
  {
    "item": "prop_torch",
    "endpoint": "create-image-pixflux",
    "error": "HTTP 422: Canvas must be size 32x32 area or larger",
    "resolution": "All props now generated at twice target width/height and downsampled nearest-neighbour. Original request saved as prop_torch.failed.request.json.",
    "charged_usd": 0
  },
  {
    "item": "title",
    "endpoint": "create-image-pixflux-background",
    "error": "240x135 dimensions must be divisible by four; async job failed before generation",
    "resolution": "Retry at 240x136, nearest-neighbour double and crop vertical one pixel per edge",
    "charged_usd": 0
  },
  {
    "item": "morrow_death_retry",
    "endpoint": "animate-with-text-v3",
    "error": "Temporary failure in name resolution; generation response not returned",
    "prompt": "Morrow the Hollow rapidly dissolves into violet smoke and vanishes into dawn. His mask and robe break apart into scattered pixels, the whole body disappears. The final frame is empty transparent background. Keep side profile facing RIGHT as he fades; no camera movement.",
    "request_file": "art/raw/morrow_death_retry.request.json",
    "usd_delta_observed_at_followup": 0,
    "spent_at_followup_usd": 0.85889748791192,
    "resolution": "No resubmission to avoid duplicate spend and a third attempt. Morrow death uses procedural placeholder.",
    "late_charge_inferred_usd": 0.03667435114913997,
    "charge_inference": "Final spent minus all successful response USD usage. The late charge is recorded in shade_hurt_retry ledger balance delta.",
    "recovery_limitation": "No job UUID returned to caller before DNS error; cannot poll/export the paid result without that UUID."
  }
]
```

## Contract validation

```json
{
  "counts": {
    "backgrounds": 5,
    "props": 13,
    "ui": 6,
    "sprites": 92,
    "tiles": 25
  },
  "issues": [
    "shade/death: missing (engine placeholder)",
    "morrow/death: missing (engine placeholder)"
  ]
}
```

## Offline rebuild verification

```json
{
  "network_used": false,
  "files_checked": 146,
  "identical": true,
  "changed_files": []
}
```
