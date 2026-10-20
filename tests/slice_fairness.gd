extends Node
## Measure actual awareness ticks with stationary actors and real light/line of sight.
func _ready() -> void:
	var level := SliceLevel.new()
	var rows: Array[String] = []
	for r in 28:
		rows.append("#".repeat(40) if r >= 24 else "#" + ".".repeat(38) + "#")
	rows[23][5] = "@"
	rows[23][10] = "g"
	level._parse("theme: 2\nmap:\n" + "\n".join(rows))
	add_child(level)
	level.skip_intro()
	var p := level.renn
	var guard := level.guards[0]
	p.set_physics_process(false)
	guard.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var times: Array[float] = []
	for lit in [false, true]:
		p.position = Vector2(280, 384)
		p.velocity = Vector2.ZERO
		p.crouched = false
		guard.position = Vector2(160, 384)
		guard.velocity = Vector2.ZERO
		guard.facing = 1
		guard.suspicion = 0
		guard.state = WatchGuard.S.SUSPICION
		level.lights.clear()
		if lit:
			level.lights.append(p.position + Vector2(0, -24))
		var ticks := 0
		while guard.state != WatchGuard.S.CHASE and ticks < 600:
			guard._physics_process(1.0 / 60.0)
			ticks += 1
			await get_tree().physics_frame
		times.append(ticks / 60.0)
	print("FAIRNESS shadow_120px=%.3fs lit_120px=%.3fs" % [times[0], times[1]])
	if times[0] < 2.5 or times[0] > 4.0 or times[1] < .8 or times[1] > 1.5:
		get_tree().quit(1)
		return
	get_tree().quit()
