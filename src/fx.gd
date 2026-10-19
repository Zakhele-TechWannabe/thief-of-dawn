class_name Fx
## Small visual helpers shared by levels and actors: light textures, particle presets, flashes.

static var _light_tex: Texture2D


## Soft radial texture for PointLight2D.
static func light_texture() -> Texture2D:
	if _light_tex == null:
		var grad := Gradient.new()
		grad.set_color(0, Color(1, 1, 1, 1))
		grad.set_color(1, Color(1, 1, 1, 0))
		grad.add_point(0.35, Color(1, 1, 1, 0.55))
		var tex := GradientTexture2D.new()
		tex.gradient = grad
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(1.0, 0.5)
		tex.width = 256
		tex.height = 256
		_light_tex = tex
	return _light_tex


static func light(color: Color, energy: float, radius_px: float) -> PointLight2D:
	var l := PointLight2D.new()
	l.texture = light_texture()
	l.color = color
	l.energy = energy
	l.texture_scale = radius_px / 128.0
	return l


static func _dot(size: int) -> Texture2D:
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	return ImageTexture.create_from_image(img)


## Embers rising from a flame.
static func embers() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = 10
	p.lifetime = 1.4
	p.texture = _dot(1)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(3, 1)
	p.direction = Vector2(0, -1)
	p.spread = 25
	p.gravity = Vector2(0, -12)
	p.initial_velocity_min = 8
	p.initial_velocity_max = 22
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.85, 0.4, 1))
	ramp.set_color(1, Color(1.0, 0.3, 0.1, 0))
	p.color_ramp = ramp
	return p


## Slow dust motes filling a rectangle (light shafts, ambient air).
static func dust(extents: Vector2, amount := 40, color := Color(1, 0.95, 0.8, 0.5)) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = amount
	p.lifetime = 8.0
	p.preprocess = 8.0
	p.texture = _dot(1)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = extents
	p.direction = Vector2(1, -0.2)
	p.spread = 180
	p.gravity = Vector2(0, 1.5)
	p.initial_velocity_min = 1
	p.initial_velocity_max = 5
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color, 0))
	ramp.add_point(0.2, color)
	ramp.add_point(0.8, color)
	ramp.set_color(1, Color(color, 0))
	p.color_ramp = ramp
	return p


## One-shot burst (hit sparks, landing dust, dissolves). Frees itself.
static func burst(parent: Node, pos: Vector2, color: Color, amount := 12, speed := 90.0,
		gravity := 200.0, lifetime := 0.45, dir := Vector2.UP, spread := 180.0, size := 1) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = lifetime
	p.texture = _dot(size)
	p.direction = dir
	p.spread = spread
	p.gravity = Vector2(0, gravity)
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	var ramp := Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color, 0))
	p.color_ramp = ramp
	p.position = pos
	parent.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)


## Briefly tint a sprite white-hot (hit flash).
static func flash(item: CanvasItem, color := Color(3, 3, 3), seconds := 0.08) -> void:
	item.modulate = color
	var t := item.create_tween()
	t.tween_property(item, "modulate", Color.WHITE, seconds)
