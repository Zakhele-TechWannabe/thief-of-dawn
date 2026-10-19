class_name LooseFloor
extends StaticBody2D
## A warning shake, then a falling slab. Checkpoint respawns restore every slab.

var level: Level
var cell: Vector2i
var _home: Vector2
var _timer := -1.0
var _fall_speed := 0.0
var _falling := false
var _shape: CollisionShape2D


func _ready() -> void:
	_home = position
	collision_layer = 1
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	_shape.shape = rect
	_shape.position = Vector2(8, 8)
	add_child(_shape)
	queue_redraw()


func _draw() -> void:
	if _timer >= 0.0 and not _falling:
		draw_set_transform(Vector2(sin(_timer * 90.0) * 1.2, 0))
	draw_rect(Rect2(0, 0, 16, 16), Color("#716975"))
	draw_rect(Rect2(0, 0, 16, 3), Color("#b1a292"))
	draw_polyline(PackedVector2Array([Vector2(9, 1), Vector2(6, 6), Vector2(10, 10), Vector2(7, 16)]), Color("#302936"), 1)


func _physics_process(delta: float) -> void:
	var p := level.player
	if not _falling:
		if _timer < 0.0 and p and p.is_on_floor() and absf(p.position.y - _home.y) < 2.0 \
				and absf(p.position.x - (_home.x + 8)) < 14.0:
			_timer = 0.0
		if _timer >= 0.0:
			_timer += delta
			# The collision stays still during the warning; only the drawing shakes.
			queue_redraw()
			if _timer >= 0.4:
				_falling = true
				_shape.set_deferred("disabled", true)
				Fx.burst(level, _home + Vector2(8, 8), Color(0.6, 0.5, 0.4), 8, 35, 160)
	elif visible:
		_fall_speed += 650.0 * delta
		position.y += _fall_speed * delta
		var below := level.cell_of(position + Vector2(8, 17))
		if level.is_solid(below.x, below.y) or position.y > level.height * 16 or position.y > _home.y + 260:
			Fx.burst(level, position + Vector2(8, 8), Color(0.65, 0.58, 0.5), 18, 65, 110, 0.8)
			visible = false


func intact() -> bool:
	return not _falling


func restore() -> void:
	position = _home
	_timer = -1.0
	_fall_speed = 0.0
	_falling = false
	visible = true
	_shape.set_deferred("disabled", false)
	queue_redraw()
