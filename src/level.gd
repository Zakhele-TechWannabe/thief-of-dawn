class_name Level
extends Node2D
## Builds a playable level from an ASCII file (levels/levelN.txt). See levels/FORMAT.md for the legend.

signal completed

const T := 16
const SOLID := "#"
const PLATFORM := "="

var info := {}                 # header values: name, theme, darkness, hints…
var rows: PackedStringArray = []
var width := 0
var height := 0
var spawn := Vector2.ZERO
var player: Player
var camera: GameCamera
var _flickers: Array = []      # [PointLight2D, base_energy, phase]


static func load_file(path: String) -> Level:
	var level := Level.new()
	level._parse(FileAccess.get_file_as_string(path))
	return level


func _parse(text: String) -> void:
	var in_map := false
	for line in text.split("\n"):
		if in_map:
			if line.strip_edges() == "" and rows.size() > 0 and line.length() == 0:
				continue
			rows.append(line.rstrip("\r"))
		elif line.strip_edges() == "map:":
			in_map = true
		elif ":" in line and not line.begins_with("#"):
			var k := line.get_slice(":", 0).strip_edges()
			info[k] = line.substr(line.find(":") + 1).strip_edges()
	height = rows.size()
	for r in rows:
		width = maxi(width, r.length())


func at(c: int, r: int) -> String:
	if r < 0 or r >= height or c < 0:
		return SOLID if r >= 0 and r < height and c < 0 else " "
	var row := rows[r]
	if c >= row.length():
		return SOLID   # beyond the right edge counts as wall
	return row[c]


func is_solid(c: int, r: int) -> bool:
	return at(c, r) == SOLID


func is_floor(c: int, r: int) -> bool:
	var ch := at(c, r)
	return ch == SOLID or ch == PLATFORM


func cell_of(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / T), floori(p.y / T))


func theme_dir() -> String:
	return "res://assets/tiles/level%s" % info.get("theme", "1")


func _ready() -> void:
	_build_background()
	_build_tiles()
	_build_objects()
	_build_foreground()
	var mod := CanvasModulate.new()
	mod.color = Color(info.get("darkness", "#52566e"))
	add_child(mod)


# --- background ---------------------------------------------------------------------------------

func _build_background() -> void:
	var bg_path := "res://assets/backgrounds/level%s.png" % info.get("theme", "1")
	if ResourceLoader.exists(bg_path):
		var far := Parallax2D.new()
		far.scroll_scale = Vector2(0.15, 0.08)
		far.repeat_size = Vector2(960, 0)
		far.repeat_times = 4
		far.z_index = -100
		var s := Sprite2D.new()
		s.texture = load(bg_path)
		s.centered = false
		s.scale = Vector2(2, 2)
		s.modulate = Color(0.75, 0.75, 0.85)
		far.add_child(s)
		add_child(far)
	# mid layer: rows of dark columns drifting at half speed, for depth
	var pillar_path := theme_dir() + "/pillar.png"
	if ResourceLoader.exists(pillar_path):
		var mid := Parallax2D.new()
		mid.scroll_scale = Vector2(0.55, 0.55)
		mid.repeat_size = Vector2(192, 0)
		mid.repeat_times = 6
		mid.z_index = -90
		var col := _column_texture(load(pillar_path), height * T + 200)
		var spr := Sprite2D.new()
		spr.texture = col
		spr.centered = false
		spr.position = Vector2(40, -100)
		spr.modulate = Color(0.22, 0.22, 0.32)
		mid.add_child(spr)
		add_child(mid)


func _column_texture(piece: Texture2D, length: int) -> Texture2D:
	var src := piece.get_image()
	src.decompress()
	var img := Image.create(src.get_width() * 2, length, false, Image.FORMAT_RGBA8)
	var big := src.duplicate()
	big.resize(src.get_width() * 2, src.get_height() * 2, Image.INTERPOLATE_NEAREST)
	var y := 0
	while y < length:
		img.blit_rect(big, Rect2i(Vector2i.ZERO, big.get_size()), Vector2i(0, y))
		y += big.get_height()
	return ImageTexture.create_from_image(img)


## Dark shapes close to the camera (chains, arches) drifting faster than the scene: depth for free.
func _build_foreground() -> void:
	var fg := Parallax2D.new()
	fg.scroll_scale = Vector2(1.3, 1.0)
	fg.repeat_size = Vector2(700, 0)
	fg.repeat_times = 8
	fg.z_index = 50
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 2:
		var x := 120.0 + i * 360.0 + rng.randf_range(-40, 40)
		var chain := Line2D.new()
		var length := rng.randf_range(90, 170)
		var pts := PackedVector2Array()
		for k in 12:
			pts.append(Vector2(x + sin(k * 0.9) * 1.5, k * length / 11.0))
		chain.points = pts
		chain.width = 4
		chain.default_color = Color(0.02, 0.02, 0.04, 0.9)
		fg.add_child(chain)
		var weight := Polygon2D.new()
		weight.polygon = PackedVector2Array([Vector2(-6, 0), Vector2(6, 0), Vector2(4, 12), Vector2(-4, 12)])
		weight.position = Vector2(x, length)
		weight.color = Color(0.02, 0.02, 0.04, 0.9)
		fg.add_child(weight)
	add_child(fg)


## A cluster of candles on the floor with a small warm light.
func _candles(feet: Vector2) -> void:
	var node := Node2D.new()
	node.position = feet
	node.z_index = -2
	var rng := RandomNumberGenerator.new()
	rng.seed = int(feet.x * 13 + feet.y)
	for i in rng.randi_range(2, 4):
		var h := rng.randi_range(3, 8)
		var x := rng.randi_range(-6, 5)
		var wax := ColorRect.new()
		wax.color = Color(0.92, 0.88, 0.75)
		wax.size = Vector2(2, h)
		wax.position = Vector2(x, -h)
		node.add_child(wax)
		var flame := ColorRect.new()
		flame.color = Color(1.0, 0.8, 0.35)
		flame.size = Vector2(1, 2)
		flame.position = Vector2(x + 0.5, -h - 2)
		node.add_child(flame)
	var light := Fx.light(Color(1.0, 0.72, 0.4), 0.7, 56)
	light.position = Vector2(0, -8)
	node.add_child(light)
	_flicker(light)
	add_child(node)


# --- tiles --------------------------------------------------------------------------------------

func _build_tiles() -> void:
	var top: Image = load(theme_dir() + "/top.png").get_image()
	var solid: Image = load(theme_dir() + "/solid.png").get_image()
	top.decompress()
	solid.decompress()
	top.convert(Image.FORMAT_RGBA8)
	solid.convert(Image.FORMAT_RGBA8)
	# atlas: 0 top, 1 solid, 2 deep solid (darker, further from air), 3 platform plank
	var atlas := Image.create(80, 16, false, Image.FORMAT_RGBA8)
	atlas.blit_rect(top, Rect2i(0, 0, 16, 16), Vector2i(0, 0))
	atlas.blit_rect(solid, Rect2i(0, 0, 16, 16), Vector2i(16, 0))
	var deep := solid.duplicate()
	for y in 16:
		for x in 16:
			deep.set_pixel(x, y, deep.get_pixel(x, y).darkened(0.62))
	atlas.blit_rect(deep, Rect2i(0, 0, 16, 16), Vector2i(32, 0))
	atlas.blit_rect(top, Rect2i(0, 0, 16, 6), Vector2i(48, 0))
	var mid := solid.duplicate()
	for y in 16:
		for x in 16:
			mid.set_pixel(x, y, mid.get_pixel(x, y).darkened(0.32))
	atlas.blit_rect(mid, Rect2i(0, 0, 16, 16), Vector2i(64, 0))
	for x in 16:   # shadow line under the plank
		atlas.set_pixel(48 + x, 6, Color(0, 0, 0, 0.6))

	var ts := TileSet.new()
	ts.tile_size = Vector2i(T, T)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	var src := TileSetAtlasSource.new()
	src.texture = ImageTexture.create_from_image(atlas)
	src.texture_region_size = Vector2i(T, T)
	ts.add_source(src, 0)
	for i in 5:
		src.create_tile(Vector2i(i, 0))
		var td := src.get_tile_data(Vector2i(i, 0), 0)
		td.add_collision_polygon(0)
		if i == 3:
			td.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, -3), Vector2(-8, -3)]))
			td.set_collision_polygon_one_way(0, 0, true)
		else:
			td.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)]))

	var layer := TileMapLayer.new()
	layer.tile_set = ts
	layer.z_index = 0
	layer.modulate = Color(info.get("stone", "#9a8f9c"))   # masonry sits darker than the lit scene
	add_child(layer)
	for r in height:
		for c in width:
			var ch := at(c, r)
			if ch == SOLID:
				var tile := 1
				if not is_solid(c, r - 1):
					tile = 0
				else:
					var d := _depth(c, r)
					tile = 1 if d <= 1 else (4 if d == 2 else 2)
				layer.set_cell(Vector2i(c, r), 0, Vector2i(tile, 0))
			elif ch == PLATFORM:
				layer.set_cell(Vector2i(c, r), 0, Vector2i(3, 0))
	# dark rim along exposed wall sides so masonry reads as solid mass
	var rim := Node2D.new()
	rim.z_index = 1
	add_child(rim)
	for r in height:
		for c in width:
			if not is_solid(c, r):
				continue
			for side in [-1, 1]:
				if c + side >= 0 and c + side < width and not is_solid(c + side, r):
					var line := ColorRect.new()
					line.color = Color(0, 0, 0, 0.45)
					line.size = Vector2(2, T)
					line.position = Vector2(c * T + (T - 2 if side == 1 else 0), r * T)
					rim.add_child(line)


func _depth(c: int, r: int) -> int:
	for d in range(1, 4):
		for dc in range(-d, d + 1):
			for dr in range(-d, d + 1):
				if not is_solid(c + dc, r + dr):
					return d
	return 4


# --- objects ------------------------------------------------------------------------------------

func _build_objects() -> void:
	for r in height:
		for c in width:
			var ch := at(c, r)
			var feet := Vector2(c * T + T / 2.0, (r + 1) * T)
			match ch:
				"@": spawn = feet
				"s": _add_enemy("shade", feet)
				"t": _torch(Vector2(c * T + 8, r * T + 8))
				"L": _lantern(c, r)
				"w": _window(c, r)
				"|": _pillar(c, r)
				"^": _spikes(c, r)
				"h": _pickup("potion_small", feet, "heal")
				"H": _pickup("potion_big", feet, "max_hp")
				"k": _checkpoint(feet)
				"E": _exit(feet)
				"b": _books(c, r)
				"c": _candles(feet)
				_:
					if ch >= "1" and ch <= "9":
						_hint_stone(feet, info.get("hint" + ch, ""))


func _flicker(light: PointLight2D) -> void:
	_flickers.append([light, light.energy, randf() * 10.0])


func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for f in _flickers:
		var l: PointLight2D = f[0]
		l.energy = f[1] * (0.88 + 0.08 * sin(t * 9.0 + f[2]) + 0.05 * sin(t * 23.0 + f[2] * 3.0))
	if player and player.global_position.y > height * T + 48:
		player.hit_hazard(1)


func _torch(pos: Vector2) -> void:
	var node := Node2D.new()
	node.position = pos
	node.z_index = -5
	var frames := SpriteFrames.new()
	for i in 3:
		var p := "res://assets/props/torch_%02d.png" % i
		if ResourceLoader.exists(p):
			frames.add_frame("default", load(p))
	frames.set_animation_speed("default", 8)
	var spr := AnimatedSprite2D.new()
	spr.sprite_frames = frames
	spr.play()
	spr.frame = randi() % 3
	node.add_child(spr)
	var light := Fx.light(Color(1.0, 0.68, 0.35), 1.15, 120)
	light.position = Vector2(0, -8)
	node.add_child(light)
	_flicker(light)
	var em := Fx.embers()
	em.position = Vector2(0, -12)
	node.add_child(em)
	add_child(node)


func _lantern(c: int, r: int) -> void:
	var node := Node2D.new()
	node.position = Vector2(c * T + 8, r * T + 16)
	node.z_index = -4
	# chain up to the ceiling
	var top := r
	while top > 0 and not is_solid(c, top - 1):
		top -= 1
	var chain := Line2D.new()
	chain.points = PackedVector2Array([Vector2(0, (top - r) * T - 16), Vector2(0, -14)])
	chain.width = 1
	chain.default_color = Color(0.25, 0.22, 0.2)
	node.add_child(chain)
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/props/lantern.png")
	node.add_child(spr)
	var light := Fx.light(Color(1.0, 0.8, 0.45), 0.9, 90)
	node.add_child(light)
	_flicker(light)
	add_child(node)
	var sway := node.create_tween().set_loops()
	sway.tween_property(node, "rotation", 0.04, 1.6).set_trans(Tween.TRANS_SINE)
	sway.tween_property(node, "rotation", -0.04, 1.6).set_trans(Tween.TRANS_SINE)


## A tall window: cold light shaft slanting down with dust in it.
func _window(c: int, r: int) -> void:
	var node := Node2D.new()
	node.position = Vector2(c * T, r * T)
	node.z_index = -20
	var win_path := theme_dir() + "/window.png"
	var frame := ColorRect.new()
	frame.color = Color(0.55, 0.65, 0.85, 0.55)
	frame.size = Vector2(16, 40)
	frame.position = Vector2(0, -12)
	node.add_child(frame)
	if ResourceLoader.exists(win_path):
		var w := Sprite2D.new()
		w.texture = load(win_path)
		w.centered = false
		w.scale = Vector2(1, 2.5)
		w.position = Vector2(0, -12)
		node.add_child(w)
	var beam := Polygon2D.new()
	beam.polygon = PackedVector2Array([Vector2(0, -10), Vector2(16, -10), Vector2(120, 210), Vector2(48, 210)])
	beam.vertex_colors = PackedColorArray([Color(0.75, 0.85, 1, 0.22), Color(0.75, 0.85, 1, 0.22), Color(0.75, 0.85, 1, 0), Color(0.75, 0.85, 1, 0)])
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	beam.material = add
	node.add_child(beam)
	var motes := Fx.dust(Vector2(30, 90), 24, Color(0.85, 0.9, 1, 0.55))
	motes.position = Vector2(55, 100)
	node.add_child(motes)
	var light := Fx.light(Color(0.6, 0.72, 1.0), 0.55, 160)
	light.position = Vector2(40, 60)
	node.add_child(light)
	add_child(node)


func _pillar(c: int, r: int) -> void:
	# a background column from this cell down to the floor
	var bottom := r
	while bottom < height - 1 and not is_floor(c, bottom + 1):
		bottom += 1
	var p := theme_dir() + "/pillar.png"
	if not ResourceLoader.exists(p):
		return
	var tex := _column_texture(load(p), (bottom - r + 1) * T)
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.position = Vector2(c * T - 8, r * T)
	s.modulate = Color(0.55, 0.55, 0.65)
	s.z_index = -30
	add_child(s)


## Bookshelf block in the background (procedural spines in Thalorian colours).
func _books(c: int, r: int) -> void:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.16, 0.11, 0.09))
	var rng := RandomNumberGenerator.new()
	rng.seed = c * 7919 + r * 104729
	var palette := [Color("#6b2b2b"), Color("#2f4a6b"), Color("#6b5a2b"), Color("#3f5f3a"), Color("#5a3a6b"), Color("#8a7a5a")]
	for shelf in 2:
		var y0 := shelf * 8
		img.fill_rect(Rect2i(0, y0 + 7, 16, 1), Color(0.3, 0.2, 0.14))
		var x := 1
		while x < 15:
			var w := rng.randi_range(1, 2)
			var h := rng.randi_range(4, 6)
			img.fill_rect(Rect2i(x, y0 + 7 - h, w, h), palette[rng.randi() % palette.size()])
			x += w + (1 if rng.randf() < 0.2 else 0)
	var s := Sprite2D.new()
	s.texture = ImageTexture.create_from_image(img)
	s.centered = false
	s.position = Vector2(c * T, r * T)
	s.modulate = Color(0.8, 0.8, 0.85)
	s.z_index = -25
	add_child(s)


func _spikes(c: int, r: int) -> void:
	var s := Sprite2D.new()
	s.texture = load("res://assets/props/spikes.png")
	s.centered = false
	s.position = Vector2(c * T, r * T)
	add_child(s)
	var area := _area(Rect2(c * T + 2, r * T + 8, T - 4, 8), 2)
	area.body_entered.connect(func(b): if b is Player: b.hit_hazard(1))


func _area(rect: Rect2, mask: int) -> Area2D:
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = mask
	var shape := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = rect.size
	shape.shape = rs
	area.position = rect.position + rect.size / 2
	area.add_child(shape)
	add_child(area)
	return area


func _pickup(prop: String, feet: Vector2, kind: String) -> void:
	var node := Node2D.new()
	node.position = feet - Vector2(0, 10)
	var s := Sprite2D.new()
	s.texture = load("res://assets/props/%s.png" % prop)
	node.add_child(s)
	var glow := Fx.light(Color(1, 0.3, 0.3) if kind == "heal" else Color(0.5, 1, 0.5), 0.6, 40)
	node.add_child(glow)
	add_child(node)
	var bob := node.create_tween().set_loops()
	bob.tween_property(s, "position:y", -3.0, 0.8).set_trans(Tween.TRANS_SINE)
	bob.tween_property(s, "position:y", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
	var area := _area(Rect2(feet - Vector2(8, 18), Vector2(16, 18)), 2)
	area.body_entered.connect(func(b):
		if b is Player and is_instance_valid(node):
			if kind == "heal":
				b.heal(2)
				Game.toast.emit("Restored")
			else:
				Game.max_hp += 1
				b.heal(99)
				Game.toast.emit("Your life grows: +1 max health")
			Fx.burst(self, node.position, Color(1, 0.5, 0.5), 16, 60, -40, 0.8)
			node.queue_free()
			area.queue_free())


func _checkpoint(feet: Vector2) -> void:
	var node := Node2D.new()
	node.position = feet
	node.z_index = -3
	var base := Polygon2D.new()
	base.polygon = PackedVector2Array([Vector2(-8, 0), Vector2(8, 0), Vector2(6, -10), Vector2(-6, -10)])
	base.color = Color(0.45, 0.42, 0.4)
	node.add_child(base)
	var s := Sprite2D.new()
	s.texture = load("res://assets/props/lantern.png")
	s.position = Vector2(0, -26)
	node.add_child(s)
	var light := Fx.light(Color(0.6, 0.75, 1.0), 0.35, 70)
	light.position = Vector2(0, -26)
	node.add_child(light)
	_flicker(light)
	add_child(node)
	var area := _area(Rect2(feet - Vector2(16, 40), Vector2(32, 40)), 2)
	area.body_entered.connect(func(b):
		if b is Player and b.checkpoint != feet:
			b.checkpoint = feet
			b.heal(99)
			light.color = Color(1.0, 0.8, 0.45)
			light.energy = 1.2
			_flicker(light)
			Fx.burst(self, feet - Vector2(0, 26), Color(1, 0.85, 0.5), 24, 70, -30, 1.0)
			Game.toast.emit("The flame remembers you"))


func _exit(feet: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = load("res://assets/props/exit_door.png")
	s.position = feet - Vector2(0, 24)
	s.z_index = -3
	add_child(s)
	var light := Fx.light(Color(1.0, 0.85, 0.6), 0.8, 80)
	light.position = feet - Vector2(0, 24)
	add_child(light)
	_flicker(light)
	var area := _area(Rect2(feet - Vector2(14, 44), Vector2(28, 44)), 2)
	area.body_entered.connect(func(b): if b is Player: b.at_exit = self)
	area.body_exited.connect(func(b): if b is Player and b.at_exit == self: b.at_exit = null)


func _hint_stone(feet: Vector2, text: String) -> void:
	var stone := Polygon2D.new()
	stone.polygon = PackedVector2Array([Vector2(-6, 0), Vector2(6, 0), Vector2(5, -14), Vector2(0, -17), Vector2(-5, -14)])
	stone.color = Color(0.38, 0.4, 0.48)
	stone.position = feet
	stone.z_index = -3
	add_child(stone)
	var rune := Fx.light(Color(0.5, 0.8, 1.0), 0.5, 30)
	rune.position = feet - Vector2(0, 8)
	add_child(rune)
	_flicker(rune)
	var area := _area(Rect2(feet - Vector2(20, 30), Vector2(40, 30)), 2)
	area.body_entered.connect(func(b): if b is Player and text != "": Game.toast.emit(text))


func _add_enemy(kind: String, feet: Vector2) -> void:
	var e := Shade.new()
	e.level = self
	e.position = feet
	add_child(e)


func add_player(p: Player) -> void:
	player = p
	p.level = self
	p.position = spawn
	p.checkpoint = spawn
	add_child(p)
	camera = GameCamera.new()
	camera.target = p
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = width * T
	camera.limit_bottom = height * T
	add_child(camera)
	camera.global_position = p.global_position
	camera.reset_smoothing()
