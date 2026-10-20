extends Node
## Uses only frame-scripted ordinary inputs. No route teleportation, guard freezing, or inventory grants.
var level: SliceLevel
var args := {}
var done := false
var offset_start := -1
var previous_sides := {}
func _ready() -> void:
	level.completed.connect(func(): done = true)
	call_deferred("run")
func run() -> void:
	var seq := {}
	var last := 0
	var actions := ["move_left","move_right","jump","up","down","dodge","attack","slice_throw","slice_interact"]
	var smoke := args.has("smoke")
	if not smoke:
		var re := RegEx.new()
		re.compile("^([0-9]+)([+-])([a-z_]+)$")
		for line in FileAccess.get_file_as_string(args.route).split("\n"):
			for step in line.get_slice("#",0).strip_edges().split(",",false):
				var m := re.search(step.strip_edges())
				if not m or m.get_string(3) not in actions or int(m.get_string(1)) > 36000:
					fail("invalid sequence " + step)
					return
				var f := int(m.get_string(1))
				# First release of horizontal movement begins the first observation/work wait.
				if m.get_string(2) == "-" and m.get_string(3) in ["move_left", "move_right"]:
					offset_start = f if offset_start < 0 else mini(offset_start, f)
				last = maxi(last,f)
				seq[f] = seq.get(f,[]) + [[m.get_string(2)=="+",m.get_string(3)]]
		if seq.is_empty():
			fail("empty sequence")
			return
		# Apply after parsing: sequence lines need not be in chronological order.
		var shifted := {}
		last = 0
		for frame in seq:
			var shifted_frame: int = frame + (int(args.get("route_offset", "0")) if offset_start >= 0 and frame > offset_start else 0)
			shifted[shifted_frame] = shifted.get(shifted_frame, []) + seq[frame]
			last = maxi(last, shifted_frame)
		seq = shifted
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in range(int(args.get("smoke","1800")) if smoke else last+181):
		if smoke and i%15==0:
			for action in actions:
				Input.action_release(action)
			for action in actions:
				if rng.randf()<.25: Input.action_press(action)
		for event in seq.get(i,[]):
			if event[0]: Input.action_press(event[1])
			else: Input.action_release(event[1])
		await get_tree().physics_frame
		# --shots=120,400,900 --shotdir=/tmp/x : save the rendered frame at those physics frames (needs a display)
		if args.has("shots") and str(i) in String(args.shots).split(","):
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/slice_%05d.png" % [args.get("shotdir", "/tmp"), i])
		if args.has("trace") and i%int(args.trace)==0:
			print("  velocity=",level.renn.velocity," crouch=",level.renn.crouched)
			print("SLICE frame=%d pos=%s state=%s flags=%s caught=%d" % [i,level.renn.position,level.renn.state,level.flags,level.caught_count])
			for g in level.guards:
				print("  guard ", g.position, " state=",g.state," face=",g.facing," suspicion=",g.suspicion," target=",g.last_known," hadrik=",g.hadrik," rail=",level.railing)
		if not level.renn.position.is_finite():
			fail("non-finite position")
			return
		if not smoke:
			for guard in level.guards:
				var relative: Vector2 = level.renn.position - guard.position
				var previous: float = previous_sides.get(guard, relative.x)
				if not guard.asleep and guard.state != WatchGuard.S.STAGGER and previous < 0 and relative.x >= 0 and relative.y < 0 and relative.y > -110 and not level.renn.is_on_floor():
					fail("jumped across a guard without landing on overhead cover at frame %d" % i)
					return
				previous_sides[guard] = relative.x
				if not guard.asleep and guard.state != WatchGuard.S.STAGGER and relative.x * guard.facing > 0 and absf(relative.x) < 60 and absf(relative.y) < 40:
					fail("within 60px in front of facing guard at frame %d" % i)
					return
		if not smoke and level.caught_count > 0:
			fail("caught during route")
			return
		if done and not smoke:
			var expected := String(args.route).get_file().get_basename()
			if level.flags.get("escape_route", "") != expected:
				fail("wrong escape route")
				return
			print("ROUTE OK slice=%s frames=%d caught=%d offset=%s" % [level.flags.get("escape_route","none"),i,level.caught_count,args.get("route_offset","0")])
			for g in level.guards:
				print("  guard ", g.position, " state=",g.state," face=",g.facing," suspicion=",g.suspicion," target=",g.last_known," hadrik=",g.hadrik," rail=",level.railing)
			get_tree().quit()
			return
	if smoke:
		print("SMOKE OK slice frames=%s" % args.smoke)
		get_tree().quit()
	else:
		fail("exit not reached")
func fail(reason: String) -> void:
	print("ROUTE FAIL slice %s pos=%s" % [reason,level.renn.position])
	get_tree().quit(1)
