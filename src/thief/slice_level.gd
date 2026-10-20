class_name SliceLevel
extends Level
## Thief-specific object vocabulary; reuses the prototype's theme-2 tile collision and decoration.
var renn: RennController
var guards: Array[WatchGuard] = []
var interactables: Array[ThiefInteractable] = []
var lights: Array[Vector2] = []
var covers: Array[Rect2] = []
var flags := {}
var stealing := false
var railing := Vector2.ZERO
var exit_pos := Vector2.ZERO
var checkpoint_state := ThiefCheckpoint.new()
var message := ""
var message_time := 0.0
var speaker: Node2D
var hint := ""
var active: ThiefInteractable
var overheard := false
var notice_seen := false
var family_seen := false
var finished := false
var intro_time := 0.0
var intro := true
var overlay: Control
var overlay_layer: CanvasLayer
var caught_count := 0

static func create() -> SliceLevel:
	var result := SliceLevel.new()
	result._parse(FileAccess.get_file_as_string("res://levels/chapter1.txt"))
	return result

func _ready() -> void:
	for pair in [["slice_interact", KEY_E, JOY_BUTTON_Y], ["slice_throw", KEY_V, JOY_BUTTON_RIGHT_SHOULDER]]:
		if not InputMap.has_action(pair[0]):
			InputMap.add_action(pair[0])
			var key := InputEventKey.new()
			key.physical_keycode = pair[1]
			InputMap.action_add_event(pair[0], key)
			var pad := InputEventJoypadButton.new()
			pad.button_index = pair[2]
			InputMap.action_add_event(pair[0], pad)
	super._ready()
	renn = RennController.new()
	renn.level = self
	renn.position = spawn
	add_child(renn)
	camera = GameCamera.new()
	camera.target = renn
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = width * 16
	camera.limit_bottom = height * 16
	add_child(camera)
	camera.position = renn.position
	camera.reset_smoothing()
	overlay_layer = CanvasLayer.new()
	overlay_layer.layer = 10
	add_child(overlay_layer)
	overlay = Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.draw.connect(_draw_hud)
	overlay_layer.add_child(overlay)
	capture_checkpoint(spawn)
	renn.set_physics_process(false)
	for guard in guards:
		guard.set_physics_process(false)

func _build_background() -> void:
	# Predawn Slateford: sky, a low moon, and two layers of Norran rooftops with a few lit windows.
	var sky := Polygon2D.new()
	sky.polygon = PackedVector2Array([Vector2(-640,-640), Vector2(width*16+640,-640), Vector2(width*16+640,height*16+640), Vector2(-640,height*16+640)])
	sky.vertex_colors = PackedColorArray([Color(.05,.07,.13), Color(.05,.07,.13), Color(.24,.26,.36), Color(.24,.26,.36)])
	sky.z_index = -100
	add_child(sky)
	var stars := Node2D.new()
	stars.z_index = -99
	var rng := RandomNumberGenerator.new()
	rng.seed = 320
	for i in 140:
		var dot := ColorRect.new()
		dot.size = Vector2.ONE * (2 if rng.randf() < .12 else 1)
		dot.position = Vector2(rng.randf_range(-200, width*16+200), rng.randf_range(-40, 220))
		dot.color = Color(.85,.88,1,rng.randf_range(.25,.8))
		stars.add_child(dot)
	add_child(stars)
	var moon_layer := Parallax2D.new()
	moon_layer.scroll_scale = Vector2(.08,.08)
	moon_layer.z_index = -98
	var moon := Polygon2D.new()
	var pts := PackedVector2Array()
	for k in 24:
		pts.append(Vector2(cos(k*TAU/24), sin(k*TAU/24))*18)
	moon.polygon = pts
	moon.color = Color(.86,.88,.8)
	moon.position = Vector2(470, 70)
	moon_layer.add_child(moon)
	var glow := Fx.light(Color(.6,.7,1), .5, 220)
	glow.position = moon.position
	moon_layer.add_child(glow)
	add_child(moon_layer)
	for layer in [[.25, Color(.035,.045,.075), 150, 7], [.5, Color(.05,.06,.1), 205, 11]]:
		var par := Parallax2D.new()
		par.scroll_scale = Vector2(layer[0], layer[0])
		par.z_index = -96 + int(layer[0]*4)
		var x := -120.0
		while x < width*16 + 600:
			var w := rng.randf_range(70, 140)
			var top: float = layer[2] + rng.randf_range(-30, 25)
			var peak := rng.randf_range(16, 34)
			var house := Polygon2D.new()
			house.polygon = PackedVector2Array([Vector2(x,top), Vector2(x+w*.5,top-peak), Vector2(x+w,top), Vector2(x+w,900), Vector2(x,900)])
			house.color = layer[1]
			par.add_child(house)
			if rng.randf() < .55:   # chimney
				var ch := ColorRect.new()
				ch.color = layer[1]
				ch.size = Vector2(8, 22)
				ch.position = Vector2(x + w*rng.randf_range(.6,.8), top-peak*.6-18)
				par.add_child(ch)
			for wi in rng.randi_range(0, 2):   # a few windows already lit before dawn
				var win := ColorRect.new()
				win.size = Vector2(5, 7)
				win.position = Vector2(x + rng.randf_range(10, w-16), top + rng.randf_range(10, 60))
				win.color = Color(1,.72,.36, .55 if layer[0] < .4 else .8)
				par.add_child(win)
			x += w + rng.randf_range(-12, 18)
		add_child(par)
	_build_interior()


## The holding house: back wall, timber frame and a barred window, so the cell and walk read as rooms.
func _build_interior() -> void:
	var spec: String = info.get("interior", "")
	if spec == "":
		return
	var n := spec.split(",")
	var rect := Rect2(int(n[0])*16, int(n[1])*16, (int(n[2])-int(n[0])+1)*16, (int(n[3])-int(n[1])+1)*16)
	var wall := Sprite2D.new()
	wall.texture = load(theme_dir() + "/solid.png")
	wall.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	wall.region_enabled = true
	wall.region_rect = Rect2(Vector2.ZERO, rect.size)
	wall.centered = false
	wall.position = rect.position
	wall.modulate = Color(.42,.4,.45)
	wall.z_index = -60
	add_child(wall)
	var frame := Node2D.new()
	frame.z_index = -59
	for x in range(int(rect.position.x) + 40, int(rect.end.x), 112):   # posts and a beam: a timber-framed Norran building
		var post := ColorRect.new()
		post.color = Color(.2,.14,.1)
		post.size = Vector2(6, rect.size.y)
		post.position = Vector2(x, rect.position.y)
		frame.add_child(post)
	var beam := ColorRect.new()
	beam.color = Color(.2,.14,.1)
	beam.size = Vector2(rect.size.x, 5)
	beam.position = rect.position + Vector2(0, 22)
	frame.add_child(beam)
	add_child(frame)
	for r in height:
		for c in width:
			if at(c, r) == "w":
				_barred_window(Vector2(c*16, r*16))


func _barred_window(pos: Vector2) -> void:
	var win := Node2D.new()
	win.position = pos
	win.z_index = -58
	var pane := ColorRect.new()
	pane.color = Color(.32,.4,.58)
	pane.size = Vector2(28, 30)
	win.add_child(pane)
	for i in 4:
		var bar := ColorRect.new()
		bar.color = Color(.12,.12,.14)
		bar.size = Vector2(2, 30)
		bar.position = Vector2(4 + i*7, 0)
		win.add_child(bar)
	var beam := Polygon2D.new()
	beam.polygon = PackedVector2Array([Vector2(0,4), Vector2(28,4), Vector2(150,250), Vector2(70,250)])
	beam.color = Color(.6,.72,1,.10)
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	beam.material = add
	win.add_child(beam)
	var light := Fx.light(Color(.55,.68,1), .55, 140)
	light.position = Vector2(60, 110)
	win.add_child(light)
	var motes := Fx.dust(Vector2(40, 90), 18, Color(.8,.86,1,.5))
	motes.position = Vector2(80, 130)
	win.add_child(motes)
	add_child(win)


func _build_foreground() -> void:
	pass

func _build_objects() -> void:
	for r in height:
		for c in width:
			var ch := at(c,r)
			var feet := Vector2(c*16+8,(r+1)*16)
			match ch:
				"@": spawn = feet
				"g", "B":
					var guard := WatchGuard.new()
					guard.level = self
					guard.position = feet
					guard.hadrik = ch == "B"
					var key := "patrol_%d_%d" % [c,r]
					for point in String(info.get(key, "%d,%d;%d,%d" % [c,r,c+6,r])).split(";"):
						var xy := point.split(",")
						guard.patrol.append(Vector2(float(xy[0])*16+8,(float(xy[1])+1)*16))
					guard.shoved.connect(func(_by): _guard_shoved(guard))
					guards.append(guard)
					add_child(guard)
				"t", "l", "c":
					lights.append(feet - Vector2(0,20))
					if ch == "t": _torch(feet - Vector2(0,24))
					elif ch == "l": _lantern(c,r)
					else: _candles(feet)
				"T", "r": _mine_decor(ch,c,r)
				"v", "d", "p", "q", "k", "o":
					var kinds := {"v":"vent", "d":"drain", "p":"loot", "q":"tool", "k":"checkpoint", "o":"pebbles"}
					var prompts := {"v":"Work the loose vent hinge", "d":"Lift the drain grate", "p":"Lift the watchman's coin pouch", "q":"Take pry hook", "k":"Rest here (checkpoint)", "o":"Pocket a pebble"}
					var item := ThiefInteractable.new()
					item.kind = kinds[ch]
					item.prompt = prompts[ch]
					item.duration = 2.0 if ch in ["v","d","p"] else .5
					item.level = self
					item.position = feet
					interactables.append(item)
					add_child(item)
					if ch in ["v", "d"]:
						item.gate = StaticBody2D.new()
						item.gate.collision_layer = 1
						item.gate.position.x = 24 if ch == "v" else 0
						var shape := CollisionShape2D.new()
						shape.shape = RectangleShape2D.new()
						shape.shape.size = Vector2(8, 160 if ch == "v" else 32)
						shape.position.y = -shape.shape.size.y/2
						item.gate.add_child(shape)
						item.add_child(item.gate)
				"n":
					var notice := DiegeticText.new()
					notice.position = feet
					add_child(notice)
				"R": railing = feet
				"E": exit_pos = feet
				"u":
					covers.append(Rect2(feet-Vector2(30,42), Vector2(60,48)))
					var crate := Polygon2D.new()
					crate.polygon = PackedVector2Array([Vector2(-28,-35),Vector2(28,-35),Vector2(28,0),Vector2(-28,0)])
					crate.position = feet
					crate.color = Color(.22,.18,.15,.92)
					crate.z_index = 2
					add_child(crate)

func _guard_shoved(guard: WatchGuard) -> void:
	if guard.hadrik and absf(guard.position.x - railing.x) < 100:
		flags["hadrik_humiliated"] = true
		guard.off_balance = false
		guard.velocity.x = signf(railing.x - guard.position.x) * 100
		say("Renn: Try holding the rail.", renn)

func clear_sight(from: Vector2, to: Vector2) -> bool:
	return get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(from,to,1)).is_empty()

func light_at(spot: Vector2) -> float:
	if renn and renn.crouched:
		for cover in covers:
			if cover.has_point(spot):
				return .05
	var value := .08
	for light in lights:
		if clear_sight(light,spot):
			value = maxf(value, 1.0 - light.distance_to(spot)/130.0)
	return clampf(value, .08, 1)

func noise(spot: Vector2, radius: float) -> void:
	for guard in guards:
		guard.hear(spot, radius)

func shout(source: WatchGuard, spot: Vector2) -> void:
	for guard in guards:
		if guard != source and guard.position.distance_to(source.position) < 240:
			guard.hear(spot, 10000)

func guards_near(spot: Vector2, radius: float) -> int:
	var count := 0
	for guard in guards:
		if guard.position.distance_to(spot) < radius and guard.state != WatchGuard.S.STAGGER:
			count += 1
	return count

func throw_pebble(spot: Vector2, speed: Vector2) -> void:
	var pebble := preload("res://src/thief/pebble.gd").new()
	pebble.level = self
	pebble.position = spot
	pebble.velocity = speed
	pebble.add_to_group("slice_pebbles")
	add_child(pebble)

func say(line: String, who: Node2D = null) -> void:
	message = line
	message_time = 3.5
	speaker = who

func work_interaction(delta: float, held: bool) -> void:
	active = null
	stealing = false
	for item in interactables:
		if not item.used and item.position.distance_to(renn.position) < 43:
			if active == null or item.position.distance_to(renn.position) < active.position.distance_to(renn.position):
				active = item
	for item in interactables:
		item.work(delta, held and active == item and absf(renn.velocity.x) < 15)
	hint = "Hold E: " + active.prompt if active else ""

func capture_checkpoint(spot: Vector2) -> void:
	checkpoint_state.capture(self,spot)
	say("Renn: A moment. Just one.")

func restore_checkpoint() -> void:
	caught_count += 1
	checkpoint_state.restore(self)
	say("Renn: Right. Less of that.", renn)

func skip_intro() -> void:
	intro = false
	say("Renn: Loose vent above. Drain below. Pick one.", renn)
	renn.set_physics_process(true)
	for guard in guards:
		guard.set_physics_process(true)

func _process(delta: float) -> void:
	super._process(delta)
	message_time = maxf(0,message_time-delta)
	if intro:
		intro_time += delta
		if intro_time > 19.2 or (intro_time > .5 and Input.is_action_just_pressed("jump")):
			skip_intro()
	overlay.queue_redraw()
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if renn and not intro and not finished:
		if renn.position.x > 500 and not overheard:
			overheard = true
			var nearest: WatchGuard = guards[0]
			for guard in guards:
				if guard.position.distance_to(renn.position) < nearest.position.distance_to(renn.position):
					nearest = guard
			say("Watchman: Road-work transfer. First light.", nearest)
		if renn.position.distance_to(Vector2(744,256)) < 55 and not notice_seen:
			notice_seen = true
			say("Renn: Picks. Shovels. The rest's scratches.", renn)
		for item in interactables:
			if item.kind == "checkpoint" and not item.used and item.position.x > 1200 and item.position.distance_to(renn.position) < 22:
				item.used = true
				renn.break_used = false
				capture_checkpoint(item.position)
		if renn.position.x > 980 and not flags.get("hadrik_humiliated",false):
			for guard in guards:
				if guard.hadrik:
					guard.off_balance = true
					if guard.position.distance_to(renn.position) < 100:
						say("Hadrik: Got you— [X: shove him into the rail]",guard)
		if renn.position.x > 1600 and not family_seen:
			family_seen = true
			say("Renn: Mother's rope frame. They'll take it. ...Keep moving.",renn)
		if renn.position.distance_to(exit_pos) < 40 and Input.is_action_just_pressed("up"):
			if flags.get("hadrik_humiliated",false):
				finished = true
				StoryState.commit(flags)
				completed.emit()
			else:
				say("Hadrik has the roof latch. Get him off the railing.")

func _draw() -> void:
	# Rope frame held as collateral, visible below the workshops. No readable world labels.
	var frame := Vector2(1660,352)
	draw_rect(Rect2(frame-Vector2(27,31),Vector2(54,5)),Color(.38,.26,.17))
	for x in [-24,24]:
		draw_line(frame+Vector2(x,-31),frame+Vector2(x,0),Color(.38,.26,.17),4)
	for y in [-23,-17,-11]:
		draw_line(frame+Vector2(-22,y),frame+Vector2(22,y),Color(.63,.53,.33),2)
	draw_arc(frame+Vector2(25,-17),10,0,TAU,18,Color(.48,.37,.23),2)
	if railing != Vector2.ZERO:
		draw_line(railing-Vector2(45,35),railing+Vector2(45,-35),Color(.45,.33,.23),4)
		for x in [-40,0,40]:
			draw_line(railing+Vector2(x,-35),railing+Vector2(x,0),Color(.35,.27,.2),3)
	if exit_pos != Vector2.ZERO:
		draw_polyline(PackedVector2Array([exit_pos+Vector2(-12,-20),exit_pos+Vector2(10,-20),exit_pos+Vector2(3,-27)]),Color(.7,.8,.85),3)

func _ui(pos: Vector2, line: String, size := 8) -> void:
	overlay.draw_string(Game.ui_font,pos,line,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color(.95,.91,.8))

## A speech box above whoever is talking, in screen space, kept on screen.
func _draw_speech() -> void:
	if intro or message_time <= 0 or speaker == null or not is_instance_valid(speaker):
		return
	var w := Game.ui_font.get_string_size(message, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
	var head := get_viewport().get_canvas_transform() * (speaker.global_position + Vector2(0, -78))
	var pos := Vector2(clampf(head.x - w/2, 8, 632 - w), clampf(head.y, 30, 300))
	overlay.draw_rect(Rect2(pos + Vector2(-5,-10), Vector2(w+10, 14)), Color(0,0,0,.72))
	overlay.draw_string(Game.ui_font, pos, message, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1,.96,.86))


func _keycap(x: float, y: float, key: String, label: String) -> float:
	var kw := Game.ui_font.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x + 6
	overlay.draw_rect(Rect2(x, y-9, kw, 11), Color(.85,.8,.65,.95))
	overlay.draw_string(Game.ui_font, Vector2(x+3, y), key, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(.1,.08,.1))
	x += kw + 4
	_ui(Vector2(x, y), label)
	return x + Game.ui_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x + 10


func _draw_hud() -> void:
	# top line: where, what he carries, whether he's in shadow
	overlay.draw_rect(Rect2(0,0,640,16),Color(0,0,0,.6))
	_ui(Vector2(8,11),"YEAR 320  /  " + ("THE LOWER ROOFS" if renn.position.x > 1150 else "BEHIND THE DOOR"))
	var kit := ("Tools: " + (", ".join(renn.tools) if renn.tools.size() else "none") + "   Carrying: " + (renn.carried if renn.carried else "nothing")).to_upper()
	var shade := "IN SHADOW" if light_at(renn.position+Vector2(0,-24)) < .3 else "IN THE LIGHT"
	var right := kit + "   " + shade
	_ui(Vector2(632 - Game.ui_font.get_string_size(right, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x, 11), right)
	# always-on controls, one line
	overlay.draw_rect(Rect2(0,344,640,16),Color(0,0,0,.6))
	var x := 6.0
	for pair in [["ARROWS","Move"],["UP","Jump/Climb"],["DOWN","Crouch"],["C","Slide"],["X","Shove"],["E","Steal/Use"],["V","Throw"]]:
		x = _keycap(x, 356, pair[0], pair[1])
	_draw_speech()
	if hint != "":
		_ui(Vector2(14,320),hint)
		if active and active.progress > 0:
			overlay.draw_rect(Rect2(14,326,200*active.progress/active.duration,3),Color(.8,.65,.35))
	if message_time > 0 and (speaker == null or not is_instance_valid(speaker)):
		_ui(Vector2(14,336),message)
	if renn.state == RennController.S.GRABBED:
		_ui(Vector2(170,80),"GRABBED! X to struggle (once, if alone)",12)
	if intro:
		overlay.draw_rect(Rect2(0,0,640,360),Color.BLACK)
		var lines := ["Hadrik: Don't make work for me today.","Renn: Then open the door.","Hadrik: You think you're funny.","Renn: You keep coming back.","Watchman: Three market thefts.","Renn: Two. Third one was from the cart."]
		var line: String = lines[mini(5,int(intro_time/3.2))]
		var w := Game.title_font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		overlay.draw_string(Game.title_font, Vector2((640-w)/2, 185), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1,.93,.78))
		_ui(Vector2(560, 340), "SPACE: skip")
