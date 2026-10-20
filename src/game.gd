extends Node
## Global state and services: input map, run progress, hit-stop and camera shake.

signal shake_requested(strength: float, duration: float)
signal player_health_changed(hp: int, max_hp: int)
signal toast(text: String)

const TILE := 16

# Keys shown in the always-on controls bar come from here, so the bar never lies about the bindings.
const BINDINGS := {
	"move_left": [KEY_LEFT, KEY_A],
	"move_right": [KEY_RIGHT, KEY_D],
	"up": [KEY_UP, KEY_W],
	"down": [KEY_DOWN, KEY_S],
	"jump": [KEY_SPACE, KEY_Z, KEY_UP, KEY_W],
	"attack": [KEY_X, KEY_J],
	"dodge": [KEY_C, KEY_L, KEY_SHIFT],
	"parry": [KEY_V, KEY_K],
	"pause": [KEY_ESCAPE, KEY_P],
	"fullscreen": [KEY_F11],
	"next_screen": [KEY_F10],
}
const PAD := {
	"jump": JOY_BUTTON_A, "attack": JOY_BUTTON_X, "dodge": JOY_BUTTON_B, "parry": JOY_BUTTON_RIGHT_SHOULDER,
	"pause": JOY_BUTTON_START, "move_left": JOY_BUTTON_DPAD_LEFT, "move_right": JOY_BUTTON_DPAD_RIGHT,
	"up": JOY_BUTTON_DPAD_UP, "down": JOY_BUTTON_DPAD_DOWN,
}

var max_hp := 5
var level := 1
var marks: Array[String] = []          # FATE marks earned; each one grants an ability (see ABILITIES)
const ABILITIES := {"traversa": "wall_jump", "ascenda": "double_jump", "enigma": "shadow_dash"}

var _hitstop_left := 0.0

## Pixel fonts drawn without antialiasing, so text stays as crisp as the art.
var ui_font: FontFile = _pixel_font("res://assets/fonts/Silkscreen-Regular.ttf")
var title_font: FontFile = _pixel_font("res://assets/fonts/PixelifySans.ttf")


static func _pixel_font(path: String) -> FontFile:
	var f: FontFile = load(path)
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.hinting = TextServer.HINTING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	return f


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for action in BINDINGS:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.3)
		for key in BINDINGS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
		if PAD.has(action):
			var pad := InputEventJoypadButton.new()
			pad.button_index = PAD[action]
			InputMap.action_add_event(action, pad)
	for pair in [["move_left", JOY_AXIS_LEFT_X, -1.0], ["move_right", JOY_AXIS_LEFT_X, 1.0],
			["up", JOY_AXIS_LEFT_Y, -1.0], ["down", JOY_AXIS_LEFT_Y, 1.0]]:
		var axis := InputEventJoypadMotion.new()
		axis.axis = pair[1]
		axis.axis_value = pair[2]
		InputMap.action_add_event(pair[0], axis)
	# OS.get_cmdline_args() includes "--screen N" when given; the saved choice only applies otherwise
	if not "--screen" in OS.get_cmdline_args():
		_restore_screen.call_deferred()


const SETTINGS := "user://settings.cfg"


## Open on the screen the player last chose (F10 moves the game to the next screen and remembers it).
func _restore_screen() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS) != OK:
		return
	var screen: int = cfg.get_value("display", "screen", -1)
	if screen >= 0 and screen < DisplayServer.get_screen_count():
		_move_to_screen(screen)


func _move_to_screen(screen: int) -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		# fullscreen windows can't be moved directly: drop to windowed, move, go back
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_current_screen(screen)
		DisplayServer.window_set_mode(mode)
	else:
		DisplayServer.window_set_current_screen(screen)


func _save_screen(screen: int) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS)
	cfg.set_value("display", "screen", screen)
	cfg.save(SETTINGS)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next_screen") and DisplayServer.get_screen_count() > 1:
		var next := (DisplayServer.window_get_current_screen() + 1) % DisplayServer.get_screen_count()
		_move_to_screen(next)
		_save_screen(next)
		toast.emit("Screen %d of %d (remembered)" % [next + 1, DisplayServer.get_screen_count()])
	if event.is_action_pressed("fullscreen"):
		var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)


func has_ability(ability: String) -> bool:
	for mark in marks:
		if ABILITIES.get(mark, "") == ability:
			return true
	return false


## Freeze the world for a few frames so hits land with weight.
func hitstop(seconds: float, scale := 0.05) -> void:
	_hitstop_left = maxf(_hitstop_left, seconds)
	Engine.time_scale = scale


func shake(strength: float, duration := 0.2) -> void:
	shake_requested.emit(strength, duration)


func _process(delta: float) -> void:
	if _hitstop_left > 0.0:
		# delta is already scaled; measure real time instead
		_hitstop_left -= delta / maxf(Engine.time_scale, 0.0001)
		if _hitstop_left <= 0.0:
			Engine.time_scale = 1.0
