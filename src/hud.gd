class_name Hud
extends CanvasLayer
## Health, location name, short messages, and a controls bar that is always on screen.

const CONTROLS := [
	["ARROWS", "Move"], ["UP/SPACE", "Jump/Climb"], ["X", "Attack"], ["C", "Dodge"], ["V", "Parry"],
	["DOWN+JUMP", "Drop"], ["F11", "Window"],
]

var area_name := ""
var _hp := 5
var _max := 5
var _toast := ""
var _toast_t := 0.0
var _name_t := 4.0
var _draw: Control


func _ready() -> void:
	layer = 10
	_draw = Control.new()
	_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
	_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_draw.draw.connect(_on_draw)
	add_child(_draw)
	Game.player_health_changed.connect(func(hp, mx): _hp = hp; _max = mx)
	Game.toast.connect(func(text): _toast = text; _toast_t = 3.0)


func _process(delta: float) -> void:
	_toast_t = maxf(0.0, _toast_t - delta)
	_name_t = maxf(0.0, _name_t - delta)
	_draw.queue_redraw()


func _text(pos: Vector2, s: String, size: int, color: Color, font: Font = null, shadow := true) -> void:
	var f: Font = font if font else Game.ui_font
	if shadow:
		_draw.draw_string(f, pos + Vector2(1, 1), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0, 0, 0, color.a * 0.8))
	_draw.draw_string(f, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _width(s: String, size: int, font: Font = null) -> float:
	return (font if font else Game.ui_font).get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x


func _on_draw() -> void:
	var vw := 640.0
	# health: diamonds like little shards of flame
	for i in _max:
		var c := Vector2(14 + i * 13, 14)
		var pts := PackedVector2Array([c + Vector2(0, -6), c + Vector2(5, 0), c + Vector2(0, 6), c + Vector2(-5, 0)])
		_draw.draw_colored_polygon(pts, Color(0, 0, 0, 0.6))
		var inner := PackedVector2Array([c + Vector2(0, -4), c + Vector2(3, 0), c + Vector2(0, 4), c + Vector2(-3, 0)])
		_draw.draw_colored_polygon(inner, Color(0.95, 0.3, 0.25) if i < _hp else Color(0.25, 0.2, 0.25))
	# location name: large on arrival, then small in the corner
	if _name_t > 0.0:
		var a := clampf(_name_t, 0.0, 1.0)
		var w := _width(area_name, 32, Game.title_font)
		_text(Vector2((vw - w) / 2, 70), area_name, 32, Color(1, 0.92, 0.75, a), Game.title_font)
	_text(Vector2(vw - _width(area_name, 8) - 10, 16), area_name, 8, Color(0.85, 0.82, 0.75, 0.8))
	# toast
	if _toast_t > 0.0:
		var a := clampf(_toast_t * 2.0, 0.0, 1.0)
		var w := _width(_toast, 8)
		_draw.draw_rect(Rect2((vw - w) / 2 - 8, 300, w + 16, 16), Color(0, 0, 0, 0.55 * a))
		_text(Vector2((vw - w) / 2, 312), _toast, 8, Color(1, 0.95, 0.8, a))
	# always-on controls bar
	_draw.draw_rect(Rect2(0, 344, vw, 16), Color(0, 0, 0, 0.6))
	var x := 8.0
	for pair in CONTROLS:
		var key: String = pair[0]
		var kw := _width(key, 8) + 6
		_draw.draw_rect(Rect2(x, 347, kw, 11), Color(0.85, 0.8, 0.65, 0.95))
		_text(Vector2(x + 3, 356), key, 8, Color(0.1, 0.08, 0.1), null, false)
		x += kw + 4
		_text(Vector2(x, 356), pair[1], 8, Color(0.9, 0.88, 0.8))
		x += _width(pair[1], 8) + 12
