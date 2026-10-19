extends Node
## Game flow: title → story card → level → card → next level. Also a pause menu and a screenshot mode:
##   godot --path . -- --level=1 --shot=/tmp/a.png --frames=90 [--at=x,y] [--hold=right,attack]

const LEVELS := ["res://levels/level1.txt", "res://levels/level2.txt"]
## Story card text lives in story/cards.md (## key, then the text) so the lore can be edited without code.
var STORY := _load_cards("res://story/cards.md")


static func _load_cards(path: String) -> Dictionary:
	var cards := {}
	var key := ""
	var lines: PackedStringArray = []
	for line in FileAccess.get_file_as_string(path).split("\n"):
		if line.begins_with("## "):
			if key != "":
				cards[key] = "\n".join(lines).strip_edges()
			key = line.substr(3).strip_edges()
			lines = []
		elif key != "":
			lines.append(line)
	if key != "":
		cards[key] = "\n".join(lines).strip_edges()
	return cards


var _args := {}
var _current: Node
var _hud: Hud
var _paused := false
var _pause_layer: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # menus keep running while the level is paused
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=")
		_args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	if _args.has("shot") or _args.has("smoke"):   # dev modes run in a window
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if _args.has("route"):
		seed(1)
		if _args.has("at") or _args.has("hold") or _args.has("seq"):
			print("ROUTE FAIL route forbids at/hold/seq, player pos unavailable")
			get_tree().quit(1)
			return
	if _args.has("level") or _args.has("route"):
		_start_level(int(_args.get("level", "1")))
	else:
		_title()


func _clear() -> void:
	if _current:
		_current.queue_free()
		_current = null
	if _hud:
		_hud.queue_free()
		_hud = null


# --- title & cards -------------------------------------------------------------------------------

func _title() -> void:
	_clear()
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := TextureRect.new()
	bg.texture = load("res://assets/ui/title.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.25)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var prompt := _label("Press SPACE to begin", 16, Game.ui_font)
	prompt.position = Vector2(0, 300)
	prompt.size = Vector2(640, 20)
	root.add_child(prompt)
	var blink := prompt.create_tween().set_loops()
	blink.tween_property(prompt, "modulate:a", 0.25, 0.8)
	blink.tween_property(prompt, "modulate:a", 1.0, 0.8)
	var layer := CanvasLayer.new()
	layer.add_child(root)
	add_child(layer)
	_current = layer
	_wait_key(func(): _card("intro", func(): _start_level(1)))


func _label(text: String, size: int, font: Font) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color(1, 0.93, 0.78))
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	return l


## Story card with a typewriter reveal; any key skips the reveal, then continues.
func _card(key: String, then: Callable) -> void:
	_clear()
	var layer := CanvasLayer.new()
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.06)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)
	var text := _label(STORY[key], 16, Game.title_font)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.position = Vector2(80, 60)
	text.size = Vector2(480, 240)
	text.visible_ratio = 0.0
	layer.add_child(text)
	var hint := _label("SPACE", 8, Game.ui_font)
	hint.position = Vector2(0, 330)
	hint.size = Vector2(640, 12)
	hint.modulate.a = 0.0
	layer.add_child(hint)
	add_child(layer)
	_current = layer
	var tw := text.create_tween()
	tw.tween_property(text, "visible_ratio", 1.0, STORY[key].length() * 0.025)
	tw.tween_property(hint, "modulate:a", 0.7, 0.4)
	_wait_key(func():
		if text.visible_ratio < 1.0:
			tw.kill()
			text.visible_ratio = 1.0
			hint.modulate.a = 0.7
			_wait_key(then)
		else:
			then.call())


var _waiting: Callable = Callable()


func _wait_key(cb: Callable) -> void:
	_waiting = cb


func _unhandled_input(event: InputEvent) -> void:
	if _waiting.is_valid() and (event.is_action_pressed("jump") or event.is_action_pressed("attack")
			or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER)):
		var cb := _waiting
		_waiting = Callable()
		get_viewport().set_input_as_handled()
		cb.call()
	elif event.is_action_pressed("pause") and _current is Level:
		_toggle_pause()


# --- levels --------------------------------------------------------------------------------------

func _start_level(n: int) -> void:
	if n < 1 or n > LEVELS.size():
		print("ROUTE FAIL invalid level, player pos unavailable" if _args.has("route") else "Invalid level")
		get_tree().quit(1)
		return
	_clear()
	Game.level = n
	# Direct starts have the same marks and health as arriving through earlier cards.
	for i in range(n - 1):
		_grant_mark(i)
	var level := Level.load_file(LEVELS[n - 1])
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(level)
	_current = level
	var p := Player.new()
	level.add_player(p)
	if _args.has("at"):
		var xy := (_args["at"] as String).split(",")
		p.global_position = Vector2(float(xy[0]), float(xy[1]))
		level.camera.global_position = p.global_position
		level.camera.reset_smoothing()
	_hud = Hud.new()
	_hud.area_name = level.info.get("name", "")
	_hud.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_hud)
	level.completed.connect(func():
		if _args.has("route"):
			_route_completed = true
			return
		if _args.has("smoke") or _args.has("shot"):
			return
		_grant_mark(n - 1)
		var next := func(): _start_level(n + 1)
		_card("after%d" % n, next if n < LEVELS.size() else _title), CONNECT_ONE_SHOT)
	if _args.has("route"):
		_route(p)
	elif _args.has("shot"):
		_screenshot_mode(p)
	elif _args.has("smoke"):
		_smoke(p)


func _toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	if _paused:
		_pause_layer = CanvasLayer.new()
		_pause_layer.layer = 20
		_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		var dim := ColorRect.new()
		dim.color = Color(0, 0, 0, 0.6)
		dim.set_anchors_preset(Control.PRESET_FULL_RECT)
		_pause_layer.add_child(dim)
		var l := _label("PAUSED\n\nESC  resume\nQ  quit to title", 16, Game.ui_font)
		l.position = Vector2(0, 120)
		l.size = Vector2(640, 120)
		_pause_layer.add_child(l)
		add_child(_pause_layer)
	elif _pause_layer:
		_pause_layer.queue_free()


func _input(event: InputEvent) -> void:
	if _paused and event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		_toggle_pause()
		_title()


# --- screenshot mode (development) ---------------------------------------------------------------

func _screenshot_mode(p: Player) -> void:
	var holds: PackedStringArray = (_args.get("hold", "") as String).split(",", false)
	for h in holds:
		Input.action_press(h)
	# --seq=10+move_right,40+jump,46-jump : press (+) or release (-) an action at a physics frame
	var seq := {}
	for step in (_args.get("seq", "") as String).split(",", false):
		var m := step.split("+") if "+" in step else step.split("-")
		seq[int(m[0])] = seq.get(int(m[0]), []) + [[("+" in step), m[1]]]
	var frames := int(_args.get("frames", "60"))
	for i in frames:
		for ev in seq.get(i, []):
			if ev[0]:
				Input.action_press(ev[1])
			else:
				Input.action_release(ev[1])
		await get_tree().physics_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_args["shot"])
	print("shot saved ", _args["shot"], " player at ", p.global_position, " hp ", p.hp, " state ", p.state)
	for e in _current.get_children():
		if e is Shade:
			print("  shade at ", e.global_position.round(), " hp ", e.hp, " state ", e.state)
	get_tree().quit()


## Headless check: mash random inputs for N frames, report, exit non-zero on obvious breakage.
func _smoke(p: Player) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(_args.get("seed", "1"))
	var actions := ["move_left", "move_right", "jump", "attack", "dodge", "parry", "up", "down"]
	var frames := int(_args.get("smoke", "1800"))
	var max_x := 0.0
	for i in frames:
		if i % 12 == 0:
			for a in actions:
				Input.action_release(a)
			Input.action_press("move_right" if rng.randf() < 0.7 else "move_left")
			for a in ["jump", "attack", "dodge", "parry"]:
				if rng.randf() < 0.25:
					Input.action_press(a)
		await get_tree().physics_frame
		max_x = maxf(max_x, p.global_position.x)
		if not is_finite(p.global_position.x) or not is_finite(p.global_position.y):
			print("SMOKE FAIL: player position is not finite")
			get_tree().quit(1)
			return
	print("SMOKE OK frames=%d max_x=%d hp=%d state=%d" % [frames, max_x, p.hp, p.state])
	get_tree().quit(0)


func _grant_mark(index: int) -> void:
	var mark: String = ["traversa", "vitaria", "ascenda", "eterna", "enigma"][index]
	if mark not in Game.marks:
		Game.marks.append(mark)
		Game.max_hp += 1


var _route_completed := false


func _route_fail(reason: String, p: Player) -> void:
	print("ROUTE FAIL %s, player pos %s hp=%d state=%d" % [reason, p.global_position, p.hp, p.state])
	get_tree().quit(1)


## Same frame+action / frame-action syntax as --seq; comments and blank lines are allowed.
## No teleport, AI steering or health changes: only ordinary Input actions.
func _route(p: Player) -> void:
	var path: String = _args["route"]
	if not FileAccess.file_exists(path):
		_route_fail("missing sequence " + path, p)
		return
	var seq := {}
	var last := 0
	var re := RegEx.new()
	re.compile("^([0-9]+)([+-])([a-z_]+)$")
	for line in FileAccess.get_file_as_string(path).split("\n"):
		line = line.get_slice("#", 0).strip_edges()
		for step in line.split(",", false):
			var m := re.search(step.strip_edges())
			if not m or not Game.BINDINGS.has(m.get_string(3)):
				_route_fail("invalid step " + step, p)
				return
			var frame := int(m.get_string(1))
			if frame > 36000:
				_route_fail("sequence exceeds 36000 frames", p)
				return
			last = maxi(last, frame)
			seq[frame] = seq.get(frame, []) + [[m.get_string(2) == "+", m.get_string(3)]]
	if seq.is_empty():
		_route_fail("empty sequence", p)
		return
	for i in range(last + 181):
		for ev in seq.get(i, []):
			if ev[0]:
				Input.action_press(ev[1])
			else:
				Input.action_release(ev[1])
		await get_tree().physics_frame
		if _args.has("trace") and i % maxi(1, int(_args["trace"])) == 0:
			print("ROUTE frame=%d pos=%s velocity=%s hp=%d state=%d" % [i, p.position, p.velocity, p.hp, p.state])
		if _route_completed:
			print("ROUTE OK level=%d frames=%d hp=%d" % [Game.level, i + 1, p.hp])
			get_tree().quit(0)
			return
		if not p.position.is_finite():
			_route_fail("non-finite position", p)
			return
		if p.state == Player.S.DEAD:
			_route_fail("Kael died", p)
			return
	_route_fail("sequence ended without completed signal", p)
