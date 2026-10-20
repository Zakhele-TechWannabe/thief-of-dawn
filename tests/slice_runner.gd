extends Node
## Uses only frame-scripted ordinary inputs. No route teleportation, guard freezing, or inventory grants.
var level: SliceLevel
var args := {}
var done := false
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
				last = maxi(last,f)
				seq[f] = seq.get(f,[]) + [[m.get_string(2)=="+",m.get_string(3)]]
		if seq.is_empty():
			fail("empty sequence")
			return
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
			print("SLICE frame=%d pos=%s state=%s flags=%s caught=%d" % [i,level.renn.position,level.renn.state,level.flags,level.caught_count])
			for g in level.guards:
				print("  guard ", g.position, " state=",g.state," face=",g.facing," suspicion=",g.suspicion," hadrik=",g.hadrik," rail=",level.railing)
		if not level.renn.position.is_finite():
			fail("non-finite position")
			return
		if done and not smoke:
			var expected := String(args.route).get_file().get_basename()
			if level.flags.get("escape_route", "") != expected:
				fail("wrong escape route")
				return
			print("ROUTE OK slice=%s frames=%d caught=%d" % [level.flags.get("escape_route","none"),i,level.caught_count])
			for g in level.guards:
				print("  guard ", g.position, " state=",g.state," face=",g.facing," suspicion=",g.suspicion," hadrik=",g.hadrik," rail=",level.railing)
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
