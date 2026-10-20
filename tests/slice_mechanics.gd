extends Node
## Deterministic integration checks using the real awareness, collision, interaction and restore systems.
var level: SliceLevel
var p: RennController
var g: WatchGuard
func check(ok: bool, reason: String) -> bool:
	if not ok:
		print("MECHANICS FAIL slice " + reason)
		get_tree().quit(1)
	return ok
func frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame
func reset_guard(spot := Vector2(168,384)) -> void:
	g.position = spot
	g.velocity = Vector2.ZERO
	g.home = spot
	g.patrol = [spot,spot+Vector2(48,0)]
	g.waypoint = 0
	g.state = WatchGuard.S.PATROL
	g.suspicion = 0
	g.facing = 1
	g.timer = 0
func _ready() -> void:
	level = SliceLevel.new()
	var rows: Array[String] = []
	for r in 28:
		var line := ""
		for c in 60:
			line += "#" if r >= 24 or c == 0 or c == 59 or (c == 20 and r > 3) else "."
		rows.append(line)
	rows[21][7] = "#"
	rows[21][8] = "#"
	rows[23][5] = "@"
	rows[23][10] = "g"
	rows[23][15] = "p"
	rows[23][18] = "d"
	level._parse("theme: 2\nmap:\n" + "\n".join(rows))
	add_child(level)
	level.skip_intro()
	p = level.renn
	g = level.guards[0]
	p.set_physics_process(false)
	await frames(3)
	# The standing collision really cannot fit; slide uses the smaller body to pass below stone.
	g.set_physics_process(false)
	p.set_physics_process(true)
	Input.action_press("move_right")
	await frames(22)
	if not check(p.position.x < 107, "standing body blocked by 32px passage"):
		return
	Input.action_press("down")
	Input.action_press("dodge")
	await frames(18)
	if not check(p.position.x > 145 and p.body.shape.size.y == 24, "slide passes low passage with smaller collision"):
		return
	for action in ["move_right", "down", "dodge"]:
		Input.action_release(action)
	p.set_physics_process(false)
	p.crouched = false
	p.velocity = Vector2.ZERO
	g.set_physics_process(true)
	# Two characters separated by a real solid wall and floor; no special LOS test double.
	p.position = Vector2(380,384)
	g.position = Vector2(280,384)
	g.facing = 1
	if not check(not g.can_see(p), "wall blocks vision"):
		return
	p.position = Vector2(280,430)
	if not check(not g.can_see(p), "floor blocks vision"):
		return
	reset_guard()
	p.position = Vector2(280,384)
	p.crouched = true
	await frames(300)
	if not check(g.state != WatchGuard.S.CHASE and g.suspicion < .3,"crouched shadow remains undetected for 5 seconds"):
		return
	reset_guard()
	p.crouched = false
	level.lights.append(Vector2(280,350))
	await frames(90)
	if not check(g.state == WatchGuard.S.CHASE,"standing lit target detected within 1.5 seconds"):
		return
	# Real arcing projectile lands; guard hears its actual contact position, searches, returns home.
	level.lights.clear()
	p.position = Vector2(380,384)
	reset_guard()
	level.throw_pebble(Vector2(230,330), Vector2(25,-80))
	await frames(55)
	if not check(g.state == WatchGuard.S.INVESTIGATE and g.last_known.x > 230,"pebble landing pulls patrol toward impact"):
		return
	await frames(600)
	if not check(g.state in [WatchGuard.S.RETURN,WatchGuard.S.PATROL] and g.position.distance_to(g.home)<65,"noise investigation searches then returns"):
		return
	g.set_physics_process(false)
	reset_guard()
	p.position = Vector2(142,384)
	p.facing = 1
	if not check(g.shove(p) and g.state == WatchGuard.S.STAGGER,"unaware guard staggered"):
		return
	g.state = WatchGuard.S.CHASE
	g.facing = -1
	g.off_balance = false
	p.grace = 0
	if not check(not g.shove(p) and p.state == RennController.S.GRABBED,"alert facing guard catches shove"):
		return
	p._enter(RennController.S.MOVE)
	p.grace = 0
	reset_guard()
	p.position = Vector2(248,384)
	level.stealing = false
	var loot: ThiefInteractable = level.interactables[0]
	loot.work(.1,true)
	if not check(g.state == WatchGuard.S.CHASE,"observed mid-steal alerts immediately"):
		return
	# Snapshot doors, guards, collected items and inventory. A committed flag lives outside it.
	reset_guard()
	p.position = Vector2(80,384)
	loot.progress = 0
	loot.used = false
	level.flags = {"escape_route":"drain"}
	StoryState.flags["slice_test_committed"] = true
	level.capture_checkpoint(p.position)
	loot.used = true
	level.interactables[1].used = true
	level.interactables[1].set_open(true)
	p.carried = "coin pouch"
	g.position.x += 70
	g.state = WatchGuard.S.CHASE
	p.grab(g)
	p.set_physics_process(true)
	await frames(105)
	p.set_physics_process(false)
	if not check(level.caught_count == 1 and p.position.distance_to(Vector2(80,384))<2,"caught struggle expires into checkpoint restore"):
		return
	if not check(g.position.distance_to(Vector2(168,384))<2 and g.state == WatchGuard.S.PATROL and not loot.used and not level.interactables[1].used and p.carried == "","checkpoint resets guards, loot, door, carry"):
		return
	if not check(StoryState.flags.get("slice_test_committed",false) and level.flags.escape_route == "drain","restore preserves committed decisions"):
		return
	await frames(2)
	if not check(not level.interactables[1].gate.get_child(0).disabled,"checkpoint grate collision restored"):
		return
	# A distant second guard cannot learn about Renn without sight or an audible shout.
	var second := WatchGuard.new()
	second.level = level
	second.position = Vector2(800,384)
	level.guards.append(second)
	level.add_child(second)
	second.set_physics_process(false)
	g.state = WatchGuard.S.PATROL
	g.last_known = Vector2(248,384)
	g.enter(WatchGuard.S.CHASE)
	if not check(second.state == WatchGuard.S.PATROL,"no telepathy beyond shout radius"):
		return
	second.position = Vector2(215,384)
	g.state = WatchGuard.S.PATROL
	g.enter(WatchGuard.S.CHASE)
	if not check(second.state == WatchGuard.S.INVESTIGATE,"nearby guard hears shout"):
		return
	# Two nearby guards prevent the once-only escape from a grab.
	p.position = Vector2(180,384)
	p.grace = 0
	p.grab(g)
	p.set_physics_process(true)
	Input.action_press("attack")
	await frames(2)
	Input.action_release("attack")
	if not check(p.state == RennController.S.GRABBED,"two guards prevent grab break"):
		return
	p.set_physics_process(false)
	second.position = Vector2(800,384)
	p.grace = 0
	p.break_used = false
	p._enter(RennController.S.MOVE)
	p.grab(g)
	p.set_physics_process(true)
	Input.action_press("attack")
	await frames(2)
	Input.action_release("attack")
	if not check(p.state == RennController.S.MOVE and p.break_used and g.state == WatchGuard.S.STAGGER,"one guard permits a single shove struggle"):
		return
	print("MECHANICS OK slice slide walls floors shadow(5s) light pebble return shove steal caught checkpoint flags shout two-guards struggle")
	get_tree().quit()
