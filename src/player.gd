class_name Player
extends CharacterBody2D
## Kael. Weighty-but-responsive movement, ledge grabs, a two-hit sword combo, dodge roll and parry.

enum S { MOVE, ATTACK, ROLL, BLOCK, HURT, HANG, CLIMB, DEAD }

# Movement (pixels, seconds). Jump apex ≈ 5.5 tiles; running jump clears ≈ 7 tiles.
const RUN := 165.0
const ACCEL := 1500.0
const AIR_ACCEL := 1000.0
const FRICTION := 1800.0
const GRAVITY := 1250.0
const FALL_MULT := 1.4           # heavier on the way down: snappier arcs
const JUMP_V := 470.0
const JUMP_CUT := 0.45           # releasing jump early cuts the rise
const MAX_FALL := 540.0
const COYOTE := 0.1
const BUFFER := 0.13
const WALL_JUMP := Vector2(210, 430)

# Combat
const ATTACKS := [
	{"anim": "attack1", "time": 0.30, "hit_from": 0.07, "hit_to": 0.17, "damage": 1, "knock": 150.0, "lunge": 90.0},
	{"anim": "attack2", "time": 0.40, "hit_from": 0.10, "hit_to": 0.22, "damage": 2, "knock": 260.0, "lunge": 130.0},
]
const COMBO_WINDOW := 0.22       # a second press within the last part of a swing chains the next one
const ROLL_TIME := 0.36
const ROLL_SPEED := 270.0
const ROLL_COOLDOWN := 0.2
const PARRY_WINDOW := 0.2        # first part of a block deflects and staggers the attacker
const INVULN := 1.0

var level: Level
var hp := 5
var facing := 1.0
var state := S.MOVE
var checkpoint := Vector2.ZERO
var safe_pos := Vector2.ZERO
var at_exit: Node = null
var riposte := 0.0               # after a parry, the next hit is a critical

var _state_time := 0.0
var _coyote := 0.0
var _buffer := 0.0
var _attack_buffer := 0.0
var _combo := 0
var _combo_queued := false
var _hit_this_swing := {}
var _roll_cd := 0.0
var _invuln := 0.0
var _air_jumps := 0
var _ledge := Vector2.ZERO
var _was_on_floor := true
var _fall_peak := 0.0

var sprite: AnimatedSprite2D
var actor := "kael2"
var _ledge_sprite: AnimatedSprite2D
var _hitbox: Area2D
var _light: PointLight2D


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 6.0
	hp = Game.max_hp
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 50)
	shape.shape = rect
	shape.position = Vector2(0, -25)
	add_child(shape)

	actor = "kael2" if FileAccess.file_exists("res://assets/sprites/kael2/meta.json") else "kael"
	sprite = Sprites.make(actor)
	add_child(sprite)
	# hang/climb art is registered on the ledge surface and drawn behind the tiles, so the ledge tile itself
	# covers the hands-and-chest band where the generated stone was removed
	if FileAccess.file_exists("res://assets/sprites/kael2_ledge/meta.json"):
		_ledge_sprite = Sprites.make("kael2_ledge")
		_ledge_sprite.z_index = -1
		_ledge_sprite.visible = false
		add_child(_ledge_sprite)

	_hitbox = Area2D.new()
	_hitbox.collision_layer = 0
	_hitbox.collision_mask = 4     # enemy bodies
	var hs := CollisionShape2D.new()
	var hr := RectangleShape2D.new()
	hr.size = Vector2(40, 34)
	hs.shape = hr
	hs.position = Vector2(24, -28)
	_hitbox.add_child(hs)
	add_child(_hitbox)

	_light = Fx.light(Color(1.0, 0.9, 0.75), 0.35, 90)
	_light.position = Vector2(0, -30)
	add_child(_light)
	Game.player_health_changed.emit(hp, Game.max_hp)


# --- input helpers -------------------------------------------------------------------------------

func _axis() -> float:
	return Input.get_axis("move_left", "move_right")


func _set_facing(dir: float) -> void:
	if dir == 0.0:
		return
	facing = signf(dir)
	Sprites.face(sprite, actor, facing)
	_hitbox.scale.x = facing


func _enter(s: S) -> void:
	state = s
	_state_time = 0.0


# --- main loop -----------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_state_time += delta
	_invuln = maxf(0.0, _invuln - delta)
	_roll_cd = maxf(0.0, _roll_cd - delta)
	riposte = maxf(0.0, riposte - delta)
	_buffer = BUFFER if Input.is_action_just_pressed("jump") else maxf(0.0, _buffer - delta)
	_attack_buffer = 0.15 if Input.is_action_just_pressed("attack") else maxf(0.0, _attack_buffer - delta)
	if state != S.HANG and state != S.CLIMB:
		sprite.visible = _invuln <= 0.0 or state == S.HURT or int(_invuln * 20) % 2 == 0

	match state:
		S.MOVE: _move(delta)
		S.ATTACK: _attack(delta)
		S.ROLL: _roll(delta)
		S.BLOCK: _block(delta)
		S.HURT: _hurt(delta)
		S.HANG: _hang(delta)
		S.CLIMB: _climb(delta)
		S.DEAD: _dead(delta)

	if state != S.HANG and state != S.CLIMB:
		move_and_slide()
	_after_move()


func _gravity(delta: float) -> void:
	var g := GRAVITY * (FALL_MULT if velocity.y > 0.0 else 1.0)
	velocity.y = minf(velocity.y + g * delta, MAX_FALL)


func _move(delta: float) -> void:
	var dir := _axis()
	_set_facing(dir)
	var on_floor := is_on_floor()
	_coyote = COYOTE if on_floor else maxf(0.0, _coyote - delta)
	if on_floor:
		_air_jumps = 1 if Game.has_ability("double_jump") else 0
	var accel := (ACCEL if dir != 0.0 else FRICTION) if on_floor else AIR_ACCEL
	velocity.x = move_toward(velocity.x, dir * RUN, accel * delta)
	_gravity(delta)

	# drop through one-way planks
	if on_floor and Input.is_action_pressed("down") and Input.is_action_just_pressed("jump") and _on_platform():
		position.y += 4
		_buffer = 0.0
	elif _buffer > 0.0:
		if _coyote > 0.0:
			_jump(JUMP_V)
		elif Game.has_ability("wall_jump") and is_on_wall_only():
			velocity = Vector2(get_wall_normal().x * WALL_JUMP.x, -WALL_JUMP.y)
			_set_facing(get_wall_normal().x)
			_buffer = 0.0
		elif _air_jumps > 0:
			_air_jumps -= 1
			_jump(JUMP_V * 0.85)
			Fx.burst(level, global_position, Color(0.7, 0.9, 1.0), 10, 60, 0, 0.4)
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

	if _attack_buffer > 0.0:
		_start_attack(0)
		return
	if Input.is_action_just_pressed("dodge") and _roll_cd <= 0.0 and on_floor:
		_start_roll()
		return
	if Input.is_action_just_pressed("parry") and on_floor:
		velocity.x = 0.0
		_enter(S.BLOCK)
		Sprites.play(sprite, "block", ["idle"])
		return
	if not on_floor and velocity.y > -60.0 and dir != 0.0 and _try_ledge():
		return
	if on_floor and at_exit and Input.is_action_just_pressed("up"):
		level.completed.emit()

	if on_floor:
		Sprites.play(sprite, "run" if absf(velocity.x) > 20.0 else "idle", ["idle"])
	else:
		Sprites.play(sprite, "jump" if velocity.y < 0.0 else "fall", ["fall", "jump", "idle"])


func _jump(v: float) -> void:
	velocity.y = -v
	_coyote = 0.0
	_buffer = 0.0
	Fx.burst(level, global_position, Color(0.8, 0.75, 0.65, 0.8), 6, 40, 120, 0.35, Vector2.UP, 70)


func _on_platform() -> bool:
	var cell := level.cell_of(global_position + Vector2(0, 2))
	return level.at(cell.x, cell.y) == Level.PLATFORM


func _after_move() -> void:
	var on_floor := is_on_floor()
	if not on_floor and _was_on_floor:
		_fall_peak = global_position.y
	if not on_floor:
		_fall_peak = minf(_fall_peak, global_position.y)
	if on_floor and not _was_on_floor and state != S.DEAD:
		var drop := global_position.y - _fall_peak
		Fx.burst(level, global_position, Color(0.8, 0.75, 0.65, 0.8), 8 if drop < 80 else 16, 50, 150, 0.4, Vector2.UP, 80)
		if drop > 140:
			Game.shake(2.0, 0.12)
	if on_floor and state == S.MOVE:
		var c := level.cell_of(global_position + Vector2(0, 2))
		if level.is_floor(c.x, c.y) and level.at(c.x - 1, c.y - 1) != "^" and level.at(c.x + 1, c.y - 1) != "^":
			safe_pos = global_position
	_was_on_floor = on_floor


# --- ledges --------------------------------------------------------------------------------------

## Grab the corner of a solid block in front when the hands pass its top edge.
func _try_ledge() -> bool:
	var hand_y := global_position.y - 46.0
	var row := floori(hand_y / Level.T)
	# forgiving: the ledge face may be up to 14 px ahead, and the hands anywhere from just above to well below its top
	for reach in [9.0, 14.0, 20.0]:
		var col := floori((global_position.x + facing * reach) / Level.T)
		for r in [row, row + 1]:
			var top_y: float = r * Level.T
			if hand_y < top_y - 6.0 or hand_y > top_y + 14.0:
				continue
			if level.is_solid(col, r) and not level.is_solid(col, r - 1) and not level.is_solid(col, r - 2) \
					and not level.is_solid(col, r - 3) and not level.is_solid(col - int(facing), r):
				_ledge = Vector2(col * Level.T + (0 if facing > 0 else Level.T), top_y)
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
		Sprites.face(_ledge_sprite, "kael2_ledge", facing)
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


# --- combat --------------------------------------------------------------------------------------

func _start_attack(i: int) -> void:
	_combo = i
	_combo_queued = false
	_attack_buffer = 0.0
	_hit_this_swing.clear()
	_set_facing(_axis())
	_enter(S.ATTACK)
	sprite.stop()
	Sprites.play(sprite, ATTACKS[i]["anim"], ["attack"])
	var a: Dictionary = ATTACKS[i]
	sprite.speed_scale = sprite.sprite_frames.get_frame_count(sprite.animation) / (a["time"] * sprite.sprite_frames.get_animation_speed(sprite.animation)) if sprite.sprite_frames else 1.0
	if is_on_floor():
		velocity.x = facing * a["lunge"]
	_swoosh(i)


func _attack(delta: float) -> void:
	var a: Dictionary = ATTACKS[_combo]
	velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
	if not is_on_floor():
		_gravity(delta)
		velocity.y = minf(velocity.y, 120.0)   # a slash briefly hangs you in the air
	if _attack_buffer > 0.0 and _state_time > a["time"] - COMBO_WINDOW and _combo + 1 < ATTACKS.size():
		_combo_queued = true
	if _state_time >= a["hit_from"] and _state_time <= a["hit_to"]:
		for body in _hitbox.get_overlapping_bodies():
			if body.has_method("take_hit") and not _hit_this_swing.has(body):
				_hit_this_swing[body] = true
				var dmg: int = a["damage"] * (3 if riposte > 0.0 else 1)
				var landed: bool = body.take_hit(dmg, facing * a["knock"], self)
				if landed:
					riposte = 0.0
					Game.hitstop(0.07 if _combo == 0 else 0.1)
					Game.shake(2.5 if _combo == 0 else 4.0, 0.12)
	if _state_time >= a["time"]:
		sprite.speed_scale = 1.0
		if _combo_queued:
			_start_attack(_combo + 1)
		else:
			_enter(S.MOVE)


## A pale arc in front of the blade so every swing reads clearly, whatever the sprite frames show.
func _swoosh(i: int) -> void:
	var arc := Line2D.new()
	var pts := PackedVector2Array()
	var r := 30.0 if i == 0 else 34.0
	var from := -1.1 if i == 0 else 1.0
	var to := 0.9 if i == 0 else -1.2
	for k in 9:
		var ang := lerpf(from, to, k / 8.0)
		pts.append(Vector2(cos(ang) * r * facing + facing * 6.0, sin(ang) * r - 30.0))
	arc.points = pts
	arc.width = 3.0 if i == 0 else 4.0
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0))
	grad.set_color(1, Color(0.85, 0.95, 1.0, 0.9))
	arc.gradient = grad
	arc.z_index = 5
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	arc.material = add
	add_child(arc)
	var t := arc.create_tween()
	t.tween_property(arc, "modulate:a", 0.0, 0.16).set_delay(0.06)
	t.tween_callback(arc.queue_free)


func _start_roll() -> void:
	_set_facing(_axis())
	_enter(S.ROLL)
	_invuln = maxf(_invuln, ROLL_TIME - 0.05)
	sprite.stop()
	Sprites.play(sprite, "roll", ["jump"])
	Fx.burst(level, global_position, Color(0.8, 0.75, 0.65, 0.8), 8, 50, 150, 0.4, Vector2(-facing, -0.5), 50)


func _roll(delta: float) -> void:
	var t := _state_time / ROLL_TIME
	velocity.x = facing * ROLL_SPEED * (1.0 - 0.6 * t)
	_gravity(delta)
	if _state_time >= ROLL_TIME:
		_roll_cd = ROLL_COOLDOWN
		_enter(S.MOVE)


func _block(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 20.0)
	_gravity(_delta)
	if _attack_buffer > 0.0:            # counter straight out of a block (a riposte after a parry)
		_start_attack(0)
		return
	if Input.is_action_just_pressed("dodge"):
		_start_roll()
		return
	if not Input.is_action_pressed("parry") and _state_time > 0.25:
		_enter(S.MOVE)


## Called by an enemy's strike. Returns "parried", "blocked" or "hit".
func receive_attack(damage: int, from: Node2D) -> String:
	if state == S.DEAD or _invuln > 0.0:
		return "miss"
	var toward := signf(from.global_position.x - global_position.x)
	if state == S.BLOCK and toward == facing:
		var spark_at := global_position + Vector2(facing * 14, -32)
		if _state_time <= PARRY_WINDOW:
			Fx.burst(level, spark_at, Color(1, 0.95, 0.6), 22, 160, 300, 0.4)
			Game.hitstop(0.16, 0.02)
			Game.shake(4.0, 0.15)
			riposte = 1.2
			Game.toast.emit("Parry! Strike now")
			return "parried"
		Fx.burst(level, spark_at, Color(1, 0.8, 0.4), 10, 110, 300, 0.3)
		velocity.x = -facing * 150.0
		Game.hitstop(0.05)
		return "blocked"
	_take_damage(damage, -toward)
	return "hit"


func _take_damage(damage: int, knock_dir: float) -> void:
	hp = maxi(0, hp - damage)
	Game.player_health_changed.emit(hp, Game.max_hp)
	Fx.flash(sprite, Color(3, 1.2, 1.2), 0.12)
	Fx.burst(level, global_position + Vector2(0, -30), Color(0.9, 0.15, 0.15), 14, 120, 400, 0.45)
	Game.shake(5.0, 0.2)
	Game.hitstop(0.1)
	sprite.speed_scale = 1.0
	if hp <= 0:
		_enter(S.DEAD)
		velocity = Vector2(knock_dir * 120.0, -180.0)
		sprite.stop()
		Sprites.play(sprite, "death", ["hurt"])
		return
	_invuln = INVULN
	velocity = Vector2(knock_dir * 200.0, -200.0)
	_enter(S.HURT)
	sprite.stop()
	Sprites.play(sprite, "hurt", ["idle"])


func _hurt(delta: float) -> void:
	_gravity(delta)
	velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
	if _state_time > 0.32:
		_enter(S.MOVE)


func _dead(delta: float) -> void:
	_gravity(delta)
	velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	if _state_time > 1.8:
		hp = Game.max_hp
		Game.player_health_changed.emit(hp, Game.max_hp)
		global_position = checkpoint
		velocity = Vector2.ZERO
		_invuln = 1.0
		_enter(S.MOVE)


## Spikes and pits: lose health and return to the last safe ground (no full restart).
func hit_hazard(damage: int) -> void:
	if state == S.DEAD:
		return
	_take_damage(damage, 0.0)
	if state != S.DEAD:
		global_position = safe_pos if safe_pos != Vector2.ZERO else checkpoint
		velocity = Vector2.ZERO
		_invuln = INVULN


func heal(amount: int) -> void:
	hp = mini(Game.max_hp, hp + amount)
	Game.player_health_changed.emit(hp, Game.max_hp)
