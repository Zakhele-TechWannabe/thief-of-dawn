extends Node
## Isolated integration checks for the new interactions, using actual physics collisions.

var level: Level
var p: Player


func _check(ok: bool, reason: String) -> bool:
	if not ok:
		print("MECHANICS FAIL " + reason)
		get_tree().quit(1)
	return ok


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _bolt(pos: Vector2, speed: Vector2, source: Shade) -> ShadowBolt:
	var bolt := ShadowBolt.new()
	bolt.level = level
	bolt.archer = source
	bolt.position = pos
	bolt.velocity = speed
	level.add_child(bolt)
	return bolt


func _ready() -> void:
	seed(1)
	level = Level.new()
	var rows := ["########################"]
	for r in range(1, 12):
		rows.append("#......................#")
	rows[11] = "#....@.........a.......#"
	rows.append("#####L##################")
	rows.append("#......................#")
	rows.append("#......................#")
	rows.append("########################")
	level._parse("theme: 2\nmap:\n" + "\n".join(rows))
	add_child(level)
	p = Player.new()
	level.add_player(p)
	var archer: ShadeArcher
	for child in level.get_children():
		if child is ShadeArcher:
			archer = child
	# No target during the first check: the manually begun draw still has to finish its telegraph.
	p.set_physics_process(false)
	archer._enter(Shade.S.WINDUP)
	await _frames(33)
	var bolts := 0
	for child in level.get_children():
		if child is ShadowBolt:
			bolts += 1
	if not _check(bolts == 0 and archer._tell.visible, "archer must telegraph before firing"):
		return
	await _frames(7)
	var fired: ShadowBolt
	for child in level.get_children():
		if child is ShadowBolt:
			fired = child
	if not _check(is_instance_valid(fired), "archer releases bolt after 0.6 s"):
		return
	fired.queue_free()
	archer.set_physics_process(false)
	# A real Area2D overlap invokes receive_attack, changes allegiance, and hits the source archer.
	p._set_facing(1)
	p._enter(Player.S.BLOCK)
	var reflected := _bolt(p.position + Vector2(16, -30), Vector2(-140, 0), archer)
	await _frames(8)
	if not _check(is_instance_valid(reflected) and reflected.reflected and p.hp == Game.max_hp, "front-facing parry reflects bolt without damage"):
		return
	await _frames(60)
	if not _check(archer.hp <= 0, "reflected bolt kills the weak archer"):
		return
	p._start_roll()
	var hp := p.hp
	var rolled := _bolt(p.position + Vector2(16, -30), Vector2(-140, 0), null)
	await _frames(20)
	if not _check(p.hp == hp and is_instance_valid(rolled) and rolled.position.x < p.position.x, "roll lets the bolt pass through"):
		return
	rolled.queue_free()
	# Jump using ordinary input while a bolt crosses the player's ground-level silhouette.
	p.position = Vector2(168, 192)
	p._invuln = 0
	p._enter(Player.S.MOVE)
	p.set_physics_process(true)
	await _frames(3)
	Input.action_press("jump")
	await _frames(10)
	var jumped := _bolt(Vector2(p.position.x + 24, 162), Vector2(-140, 0), null)
	await _frames(18)
	Input.action_release("jump")
	if not _check(p.hp == hp and is_instance_valid(jumped) and jumped.position.x < p.position.x, "jump clears the bolt"):
		return
	jumped.queue_free()
	await _frames(35)
	p.position = Vector2(88, 192)
	p.velocity = Vector2.ZERO
	# Return to normal simulation: standing triggers the slab, then a real death respawn restores it.
	p._invuln = 0
	p._enter(Player.S.MOVE)
	p.set_physics_process(true)
	var slab: LooseFloor = level._loose[Vector2i(5, 12)]
	await _frames(20)
	if not _check(slab.intact(), "loose floor warns before falling"):
		return
	await _frames(12)
	if not _check(not slab.intact(), "standing on loose floor triggers collapse"):
		return
	await _frames(50)
	if not _check(not slab.visible, "falling slab breaks against lower stone"):
		return
	p._take_damage(99, 0)
	await _frames(113)
	if not _check(p.hp == Game.max_hp and slab.intact() and slab.visible, "checkpoint respawn restores loose floor"):
		return
	print("MECHANICS OK telegraph parry reflection roll jump collapse respawn")
	get_tree().quit(0)
