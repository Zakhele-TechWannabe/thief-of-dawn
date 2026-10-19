class_name GameCamera
extends Camera2D
## Follows the player with look-ahead in the facing direction, a soft vertical band, and shake.

var target: Node2D
var _look := 0.0
var _shake := 0.0
var _shake_time := 0.0


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 7.0
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	Game.shake_requested.connect(func(s, d): _shake = maxf(_shake, s); _shake_time = maxf(_shake_time, d))


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var facing: float = target.get("facing") if target.get("facing") != null else 1.0
	_look = lerpf(_look, facing * 48.0, 1.0 - exp(-2.5 * delta))
	var goal := target.global_position + Vector2(_look, -40)
	# vertical: only follow when the player leaves a band, so small hops don't bob the view
	var dy := goal.y - global_position.y
	if absf(dy) > 36 or target.is_on_floor():
		global_position.y = goal.y if absf(dy) > 120 else global_position.y + dy * minf(1.0, 6.0 * delta)
	global_position.x = goal.x
	if _shake_time > 0.0:
		_shake_time -= delta
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
		if _shake_time <= 0.0:
			_shake = 0.0
			offset = Vector2.ZERO
