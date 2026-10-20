class_name WatchGuard
extends CharacterBody2D
## Awareness is local. Only visible targets and audible noises/shouts update last_known.
signal shoved(by: Node2D)

enum S { PATROL, SUSPICION, INVESTIGATE, CHASE, SEARCH, RETURN, STAGGER }
var level: Node2D
var state := S.PATROL
var facing := 1.0
var suspicion := 0.0
var last_known := Vector2.ZERO
var home := Vector2.ZERO
var patrol: Array[Vector2] = []
var waypoint := 0
var timer := 0.0
var hadrik := false
var off_balance := false
var sprite: AnimatedSprite2D
var bark := ""
var bark_time := 0.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	home = position
	if patrol.is_empty():
		patrol = [position, position + Vector2(96, 0)]
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(16, 44)
	shape.position.y = -22
	add_child(shape)
	sprite = Sprites.make("watch_standin")
	if hadrik:
		sprite.modulate = Color(.85, .9, 1.12)
	add_child(sprite)

func enter(next: S) -> void:
	if state == next:
		return
	state = next
	timer = 0
	var lines := ["Long night.", "What was that?", "I'll look.", "Boy! Stop!", "He was here.", "Back to my post.", "Oof!"]
	bark = lines[state]
	bark_time = 2
	if state == S.CHASE:
		level.shout(self, last_known)

func can_see(p: Node2D) -> bool:
	var eye := position + Vector2(0, -35)
	var target := p.position + Vector2(0, -12 if p.crouched else -28)
	var offset := target - eye
	if offset.length() > 245 or offset.x * facing < 0 or absf(offset.y) > absf(offset.x) * .55 + 18:
		return false
	return level.clear_sight(eye, target)

func detection_rate(p: Node2D) -> float:
	var lit: float = level.light_at(p.position + Vector2(0, -24))
	# fair for a first-timer: ~3 s to spot a boy standing in shadow, ~1 s in lantern light, slower far away
	var rate := .25 + lit * .9
	rate *= lerpf(1.3, .55, clampf(position.distance_to(p.position) / 245.0, 0, 1))
	if p.crouched and lit < .3:
		rate = .025
	elif p.crouched:
		rate *= .35
	if absf(p.velocity.x) > 80:
		rate *= 1.4
	if position.distance_to(p.position) < 65:
		rate *= 2
	return rate

func hear(spot: Vector2, radius: float) -> void:
	if state in [S.CHASE, S.STAGGER] or position.distance_to(spot) > radius:
		return
	var strength := 1.0 - position.distance_to(spot) / radius
	if strength < .12:
		return
	last_known = spot
	suspicion = maxf(suspicion, .3)
	enter(S.INVESTIGATE)

func stagger() -> void:
	enter(S.STAGGER)
	velocity.x = 0

func shove(p: Node2D) -> bool:
	if state == S.STAGGER:
		return false
	if state == S.CHASE and signf(p.position.x - position.x) == facing and not off_balance:
		bark = "Nice try."
		bark_time = 2
		p.grab(self)
		return false
	stagger()
	velocity.x = p.facing * 90
	shoved.emit(p)
	return true

func _physics_process(delta: float) -> void:
	timer += delta
	bark_time = maxf(0, bark_time - delta)
	var p: Node2D = level.renn
	var sees := p != null and can_see(p)
	if sees and state != S.STAGGER:
		last_known = p.position
		suspicion = minf(1, suspicion + detection_rate(p) * delta)
		if level.stealing:
			suspicion = 1
		if suspicion >= 1:
			enter(S.CHASE)
		elif state == S.PATROL:
			enter(S.SUSPICION)
	elif state != S.CHASE:
		suspicion = maxf(0, suspicion - delta * .12)
	if state != S.STAGGER:
		velocity.x = 0
	var goal := position
	var speed := 42.0
	match state:
		S.PATROL:
			goal = patrol[waypoint]
			if absf(goal.x - position.x) < 6:
				waypoint = (waypoint + 1) % patrol.size()
		S.SUSPICION:
			if not sees and timer > 1:
				enter(S.INVESTIGATE)
		S.INVESTIGATE:
			goal = last_known
			if absf(goal.x - position.x) < 12 or timer > 4:
				enter(S.SEARCH)
		S.CHASE:
			speed = 115
			goal = last_known
			if not sees and timer > 1.2:
				enter(S.SEARCH)
			if sees and position.distance_to(p.position) < 27:
				p.grab(self)
		S.SEARCH:
			if fmod(timer, 1.2) < delta:
				facing *= -1
			if timer > 3.5:
				enter(S.RETURN)
		S.RETURN:
			goal = home
			if absf(goal.x - position.x) < 8:
				suspicion = 0
				enter(S.PATROL)
		S.STAGGER:
			velocity.x = move_toward(velocity.x, 0, 160 * delta)
			if timer > 1.5:
				suspicion = .5
				enter(S.SEARCH)
	if absf(goal.x - position.x) > 6 and state != S.STAGGER:
		facing = signf(goal.x - position.x)
		var cell: Vector2i = level.cell_of(position + Vector2(facing * 14, 4))
		if level.is_floor(cell.x, cell.y):
			velocity.x = facing * speed
	velocity.y = minf(540, velocity.y + 1250 * delta)
	move_and_slide()
	Sprites.face(sprite, "watch_standin", facing)
	sprite.rotation = sin(timer * 16) * .12 if state == S.STAGGER else 0.0
	Sprites.play(sprite, "hurt" if state == S.STAGGER else ("walk" if absf(velocity.x) > 5 else "idle"), ["idle"])
	queue_redraw()

func _draw() -> void:
	# Ray-clipped fan: the visible cone ends at the same walls as perception.
	var eye := Vector2(0, -35)
	var fan := PackedVector2Array([eye])
	for i in 13:
		var angle := lerpf(-.48, .48, i / 12.0)
		var end := position + eye + Vector2(cos(angle) * facing, sin(angle)) * 245
		var hit := get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(position + eye, end, 1))
		fan.append((hit.position if not hit.is_empty() else end) - position)
	draw_colored_polygon(fan, Color(1, .77, .36, .055))
	if suspicion > .02 or state == S.CHASE:
		draw_string(Game.ui_font, Vector2(-4, -62), "!" if state == S.CHASE else "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, .7, .2))
		draw_rect(Rect2(-10, -58, 20, 3), Color(.15, .13, .17))
		draw_rect(Rect2(-10, -58, 20 * suspicion, 3), Color(1, .65, .2))
	if bark_time > 0:
		var bw := Game.ui_font.get_string_size(bark, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
		draw_rect(Rect2(Vector2(-bw/2 - 4, -86), Vector2(bw + 8, 13)), Color(0, 0, 0, .65))
		draw_string(Game.ui_font, Vector2(-bw/2, -76), bark, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1, .9, .8))
