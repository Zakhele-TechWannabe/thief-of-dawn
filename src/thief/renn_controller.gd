class_name RennController
extends CharacterBody2D
## Independent thief controller. Shared movement constants and ledge registration with Kael.
enum S { MOVE, HANG, CLIMB, GRABBED }
const RUN := 165.0
const GRAVITY := 1250.0
const JUMP_V := 470.0
var level: Node2D
var facing := 1.0
var state := S.MOVE
var crouched := false
var tools: Array[String] = []
var pebbles := 1          # thrown stones: a count, not a tool slot
var carried := ""
var grabber: Node2D
var break_used := false
var grace := 0.0
var slide := 0.0
var cooldown := 0.0
var _coyote := 0.0
var _buffer := 0.0
var _state_time := 0.0
var _ledge := Vector2.ZERO
var _step := 0.0
var sprite: AnimatedSprite2D
var _ledge_sprite: AnimatedSprite2D
var actor := "renn_standin"
var body: CollisionShape2D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 6
	body = CollisionShape2D.new()
	body.shape = RectangleShape2D.new()
	body.shape.size = Vector2(14, 50)
	body.position.y = -25
	add_child(body)
	actor = "renn" if FileAccess.file_exists("res://assets/sprites/renn/meta.json") else "renn_standin"
	sprite = Sprites.make(actor)
	add_child(sprite)
	_ledge_sprite = Sprites.make("renn_standin_ledge")
	_ledge_sprite.z_index = -1
	_ledge_sprite.visible = false
	add_child(_ledge_sprite)

func _axis() -> float:
	return Input.get_axis("move_left", "move_right")

func _enter(s: S) -> void:
	state = s
	_state_time = 0

func _physics_process(delta: float) -> void:
	_state_time += delta
	grace = maxf(0, grace - delta)
	cooldown = maxf(0, cooldown - delta)
	_step += delta
	if state == S.GRABBED:
		velocity = Vector2.ZERO
		if Input.is_action_just_pressed("attack") and not break_used and level.guards_near(position, 130) == 1:
			break_used = true
			grabber.stagger()
			grabber.shoved.emit(self)
			_enter(S.MOVE)
			grace = 2
			level.say("Renn: Mind the elbow.", self)
		elif _state_time > 1.6:
			level.restore_checkpoint()
		elif _state_time > .85:
			position.x = move_toward(position.x, level.checkpoint_state.data.spawn.x, 35 * delta)
			grabber.position.x = position.x + 18
		return
	if state == S.HANG:
		_hang(delta)
		return
	if state == S.CLIMB:
		_climb(delta)
		return
	var grounded := is_on_floor()
	var dir := _axis()
	if dir != 0:
		facing = signf(dir)
	Sprites.face(sprite, actor, facing)
	_coyote = .1 if grounded else maxf(0, _coyote - delta)
	_buffer = .13 if Input.is_action_just_pressed("jump") else maxf(0, _buffer - delta)
	if Input.is_action_just_pressed("dodge") and grounded and cooldown <= 0:
		slide = .36
		cooldown = .56
	slide = maxf(0, slide - delta)
	# Stay small under a low ceiling even after releasing crouch.
	var ceiling := PhysicsRayQueryParameters2D.create(position + Vector2(0, -20), position + Vector2(0, -51), 1)
	crouched = Input.is_action_pressed("down") or slide > 0 or (crouched and not get_world_2d().direct_space_state.intersect_ray(ceiling).is_empty())
	body.shape.size.y = 24 if crouched else 50
	body.position.y = -12 if crouched else -25
	sprite.scale.y = .55 if crouched else 1.0
	var speed := 62.0 if crouched else RUN
	velocity.x = facing * 270 if slide > 0 else move_toward(velocity.x, dir * speed, (1500 if grounded else 1000) * delta)
	velocity.y = minf(540, velocity.y + GRAVITY * (1.4 if velocity.y > 0 else 1.0) * delta)
	if _buffer > 0 and _coyote > 0 and not crouched:
		velocity.y = -JUMP_V
		_buffer = 0
		_coyote = 0
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= .45
	if not grounded and velocity.y > -60 and dir != 0 and not crouched and _try_ledge():
		return
	if Input.is_action_just_pressed("attack") and cooldown <= 0:
		cooldown = .4
		for guard in level.guards:
			if absf(guard.position.y - position.y) < 40 and absf(guard.position.x - position.x) < 46 and signf(guard.position.x - position.x) == facing:
				guard.shove(self)
		_act("shove", .35)
	if Input.is_action_just_pressed("slice_throw"):
		if carried != "":
			carried = ""
			level.noise(position, 200)
		elif pebbles > 0:
			pebbles -= 1
			level.throw_pebble(position + Vector2(0, -32), Vector2(facing * 210, -230))
			_act("throw", .3)
	level.work_interaction(delta, Input.is_action_pressed("slice_interact"))
	var falling := velocity.y
	move_and_slide()
	if is_on_floor() and not grounded and falling > 160:
		level.noise(position, 130)
	if grounded and absf(velocity.x) > 100 and _step > .42:
		_step = 0
		level.noise(position, 95)
	_animate(delta)
	if position.y > level.height * 16 + 50:
		level.restore_checkpoint()

func grab(guard: Node2D) -> void:
	if grace > 0 or state == S.GRABBED:
		return
	grabber = guard
	_enter(S.GRABBED)
	_show_ledge_sprite("")
	level.say(("Hadrik: Back inside." if guard.get("hadrik") else "Watchman: Got you, boy.") + "  [X: struggle]", guard)
	level.tip("grabbed", "Grabbed! Tap X to twist free. It works once, and only if he's alone.")

func _try_ledge() -> bool:
	var hand_y := global_position.y - 46.0
	var row := floori(hand_y / 16)
	# forgiving: the ledge face may be up to 14 px ahead, and the hands anywhere from just above to well below its top
	for reach in [9.0, 14.0, 20.0]:
		var col := floori((global_position.x + facing * reach) / 16)
		for r in [row, row + 1]:
			var top_y: float = r * 16
			if hand_y < top_y - 6.0 or hand_y > top_y + 14.0:
				continue
			if level.is_solid(col, r) and not level.is_solid(col, r - 1) and not level.is_solid(col, r - 2) \
					and not level.is_solid(col, r - 3) and not level.is_solid(col - int(facing), r):
				_ledge = Vector2(col * 16 + (0 if facing > 0 else 16), top_y)
				global_position = Vector2(_ledge.x - facing * 8.0, top_y + 46.0)
				velocity = Vector2.ZERO
				_enter(S.HANG)
				_show_ledge_sprite("hang")
				return true
	return false


func _hang(_delta: float) -> void:
	if _state_time < 0.12:
		return
	if Input.is_action_just_pressed("jump") or Input.is_action_pressed("up") or (_axis() == facing and _state_time > 0.25):
		_enter(S.CLIMB)
		_show_ledge_sprite("climb")
	elif Input.is_action_just_pressed("down") or _axis() == -facing:
		_enter(S.MOVE)
		_show_ledge_sprite("")
		global_position.x -= facing * 3.0


func _climb(_delta: float) -> void:
	# the art does the lifting; the body stays put until the last frames, then eases onto the ledge
	var dur := 0.5
	var t := clampf(_state_time / dur, 0.0, 1.0)
	if _ledge_sprite:
		_place_ledge_sprite()
	if _ledge_sprite == null:
		global_position.y = lerpf(_ledge.y + 46.0, _ledge.y, t)
	if t >= 1.0:
		global_position = Vector2(_ledge.x + facing * 10.0, _ledge.y)
		velocity = Vector2.ZERO
		_show_ledge_sprite("")
		_enter(S.MOVE)


## Swap between the normal sprite and the ledge-registered one ("" = back to normal).
func _show_ledge_sprite(anim: String) -> void:
	if _ledge_sprite == null:
		Sprites.play(sprite, "hang" if anim == "hang" else "jump", ["fall"])
		return
	_ledge_sprite.visible = anim != ""
	sprite.visible = anim == ""
	if anim != "":
		Sprites.face(_ledge_sprite, "renn_standin_ledge", facing)
		_ledge_sprite.stop()
		Sprites.play(_ledge_sprite, anim)
		_place_ledge_sprite()


## The ledge art is drawn front-on: the hanging body must sit just outside the wall face (12 px from the corner),
## then slide onto the ledge over the climb's second half. Origin = ledge surface; ours = feet, 46 px lower.
func _place_ledge_sprite() -> void:
	var from_corner := -12.0
	if state == S.CLIMB and _ledge_sprite.sprite_frames:
		var n := _ledge_sprite.sprite_frames.get_frame_count("climb")
		var k := clampf((_ledge_sprite.frame - 2.0) / maxf(1.0, n - 3.0), 0.0, 1.0)
		from_corner = lerpf(-12.0, 12.0, k)
	var corner_rel := _ledge.x - global_position.x
	_ledge_sprite.position = Vector2(corner_rel + facing * from_corner, -46.0)




var _action := ""
var _action_t := 0.0


## Play a short one-shot action (shove, throw) over whatever else he is doing.
func _act(anim: String, seconds: float) -> void:
	_action = anim
	_action_t = seconds
	sprite.stop()


func _animate(delta: float) -> void:
	_action_t = maxf(0.0, _action_t - delta)
	if _action_t > 0.0:
		Sprites.play(sprite, _action, ["idle"])
	elif slide > 0:
		Sprites.play(sprite, "slide", ["roll", "run"])
	elif not is_on_floor():
		Sprites.play(sprite, "jump" if velocity.y < 0 else "fall", ["jump", "idle"])
	elif crouched:
		Sprites.play(sprite, "sneak", ["idle"])
		sprite.speed_scale = 1.0 if absf(velocity.x) > 8 else 0.0   # crouched still: hold the pose
		return
	else:
		Sprites.play(sprite, "run" if absf(velocity.x) > 12 else "idle", ["idle"])
	sprite.speed_scale = 1.0
