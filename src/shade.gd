class_name Shade
extends CharacterBody2D
## Tenebri shade: patrols, spots Kael, closes in, telegraphs a strike (eyes flare), sometimes blocks.
## Parrying its strike staggers it; it dies by dissolving into shadow.

enum S { PATROL, CHASE, WINDUP, STRIKE, RECOVER, STAGGER, HURT, DEAD }

const SPEED := 55.0
const CHASE_SPEED := 95.0
const GRAVITY := 1250.0
const SIGHT := Vector2(180, 56)
const REACH := 34.0
const WINDUP := 0.5
const STRIKE := 0.18
const RECOVER := 0.55
const STAGGER := 1.3

var level: Level
var hp := 3
var facing := -1.0
var state := S.PATROL
var block_chance := 0.3
var _t := 0.0
var _struck := false
var _patrol_turn := 0.0

var sprite: AnimatedSprite2D
var actor := "shade2"
var _eyes: PointLight2D
var _tell: Polygon2D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 44)
	shape.shape = rect
	shape.position = Vector2(0, -22)
	add_child(shape)
	actor = "shade2" if FileAccess.file_exists("res://assets/sprites/shade2/meta.json") else "shade"
	sprite = Sprites.make(actor)
	add_child(sprite)
	Sprites.play(sprite, "idle")
	_eyes = Fx.light(Color(0.75, 0.55, 1.0), 0.45, 34)
	_eyes.position = Vector2(4, -38)
	add_child(_eyes)
	# warning glint shown during the wind-up so the strike is always readable
	_tell = Polygon2D.new()
	_tell.polygon = PackedVector2Array([Vector2(0, -5), Vector2(5, 0), Vector2(0, 5), Vector2(-5, 0)])
	_tell.color = Color(1.0, 0.35, 0.35)
	_tell.position = Vector2(0, -56)
	_tell.visible = false
	add_child(_tell)
	_set_facing(facing)


func _set_facing(dir: float) -> void:
	facing = signf(dir) if dir != 0.0 else facing
	Sprites.face(sprite, actor, facing)
	_eyes.position.x = 4.0 * facing


func _enter(s: S) -> void:
	state = s
	_t = 0.0


func _player() -> Player:
	return level.player if level else null


func _physics_process(delta: float) -> void:
	_t += delta
	velocity.y = minf(velocity.y + GRAVITY * delta, 540.0)
	var p := _player()
	var to_p := (p.global_position - global_position) if p else Vector2(9999, 9999)
	var sees := p != null and p.state != Player.S.DEAD and absf(to_p.x) < SIGHT.x and absf(to_p.y) < SIGHT.y
	_tell.visible = state == S.WINDUP

	match state:
		S.PATROL:
			Sprites.play(sprite, "walk", ["idle"])
			velocity.x = facing * SPEED
			_patrol_turn -= delta
			if (_edge_ahead() or is_on_wall()) and _patrol_turn <= 0.0:
				_set_facing(-facing)
				_patrol_turn = 0.4
			if sees:
				_enter(S.CHASE)
		S.CHASE:
			_set_facing(to_p.x)
			if not sees:
				_enter(S.PATROL)
			elif absf(to_p.x) <= REACH:
				velocity.x = 0.0
				_enter(S.WINDUP)
				Sprites.play(sprite, "idle")
			else:
				velocity.x = 0.0 if _edge_ahead() else facing * CHASE_SPEED
				Sprites.play(sprite, "walk", ["idle"])
		S.WINDUP:
			velocity.x = 0.0
			_eyes.energy = 0.45 + 1.6 * (_t / WINDUP)
			_tell.scale = Vector2.ONE * (1.0 + 0.4 * sin(_t * 30.0))
			if _t >= WINDUP:
				_struck = false
				_enter(S.STRIKE)
				sprite.stop()
				Sprites.play(sprite, "attack")
				velocity.x = facing * 120.0
		S.STRIKE:
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if not _struck and _t > 0.05 and p and absf(to_p.x) < REACH + 14.0 and absf(to_p.y) < 40.0 \
					and signf(to_p.x) == facing:
				_struck = true
				var result := p.receive_attack(1, self)
				if result == "parried":
					_stagger()
			if state == S.STRIKE and _t >= STRIKE:
				_eyes.energy = 0.45
				_enter(S.RECOVER)
		S.RECOVER:
			velocity.x = 0.0
			Sprites.play(sprite, "idle")
			if _t >= RECOVER:
				_enter(S.CHASE if sees else S.PATROL)
		S.STAGGER:
			velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
			sprite.rotation = sin(_t * 18.0) * 0.06
			if _t >= STAGGER:
				sprite.rotation = 0.0
				sprite.modulate = Color.WHITE
				_enter(S.CHASE)
		S.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 700.0 * delta)
			if _t >= 0.28:
				_enter(S.CHASE)
		S.DEAD:
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
	move_and_slide()


func _edge_ahead() -> bool:
	var ahead := global_position + Vector2(facing * 12.0, 4.0)
	var c := level.cell_of(ahead)
	return not level.is_floor(c.x, c.y) or level.at(c.x, c.y - 1) == "^"


func _stagger() -> void:
	_enter(S.STAGGER)
	sprite.stop()
	Sprites.play(sprite, "hurt", ["idle"])
	sprite.modulate = Color(0.7, 0.7, 1.2)
	velocity.x = -facing * 160.0
	_eyes.energy = 0.1


## Returns true when the hit landed (false when blocked).
func take_hit(damage: int, knock: float, from: Node2D) -> bool:
	if state == S.DEAD:
		return false
	var from_front := signf(from.global_position.x - global_position.x) == facing
	var can_block := state in [S.PATROL, S.CHASE] and from_front
	if can_block and randf() < block_chance:
		Sprites.play(sprite, "block", ["idle"])
		Fx.burst(level, global_position + Vector2(facing * 12, -30), Color(1, 0.85, 0.5), 10, 120, 300, 0.3)
		Game.hitstop(0.04)
		if from is Player:
			from.velocity.x = -signf(knock) * 160.0
		return false
	hp -= damage
	Fx.flash(sprite)
	Fx.burst(level, global_position + Vector2(0, -26), Color(0.6, 0.35, 0.9), 14 + damage * 4, 140, 250, 0.5,
		Vector2(signf(knock), -0.4), 60)
	if hp <= 0:
		_die(knock)
		return true
	if state != S.STAGGER:
		_enter(S.HURT)
		sprite.stop()
		Sprites.play(sprite, "hurt", ["idle"])
	velocity.x = knock
	_set_facing(-signf(knock))
	return true


## Tenebri don't leave bodies: the shade comes apart into drifting shadow.
func _die(knock: float) -> void:
	_enter(S.DEAD)
	collision_layer = 0
	_tell.visible = false
	velocity.x = knock * 0.6
	sprite.stop()
	Sprites.play(sprite, "death", ["hurt"])
	for i in 3:
		Fx.burst(level, global_position + Vector2(randf_range(-8, 8), -10 - i * 14), Color(0.35, 0.2, 0.55, 0.9),
			18, 50, -60, 1.4, Vector2.UP, 120, 2)
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(0.4, 0.2, 0.7, 0.0), 0.9)
	t.parallel().tween_property(_eyes, "energy", 0.0, 0.5)
	t.tween_callback(queue_free)
