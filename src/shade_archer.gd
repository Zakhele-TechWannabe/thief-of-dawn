class_name ShadeArcher
extends Shade
## A frail shade that retreats to bow range, draws for 0.6 s, then looses a slow bolt.

const DRAW_TIME := 0.6


func _ready() -> void:
	super._ready()
	hp = 2
	block_chance = 0.0
	sprite.self_modulate = Color(0.75, 0.5, 1.0)
	_tell.color = Color(0.85, 0.6, 1.0)


func _draw() -> void:
	if state == S.DEAD:
		return
	# Bow silhouette also reads when no sprite art is available.
	if sprite.sprite_frames == null:
		draw_circle(Vector2(0, -36), 7, Color(0.4, 0.25, 0.6))
		draw_line(Vector2(0, -29), Vector2(0, -5), Color(0.4, 0.25, 0.6), 10)
	var x := facing * 16.0
	draw_polyline(PackedVector2Array([Vector2(x - facing * 5, -44), Vector2(x + facing * 3, -29), Vector2(x - facing * 5, -14)]), Color(0.7, 0.5, 0.85), 2)
	var pull := -facing * 8.0 if state == S.WINDUP else 0.0
	draw_polyline(PackedVector2Array([Vector2(x - facing * 5, -44), Vector2(x + pull, -29), Vector2(x - facing * 5, -14)]), Color(0.9, 0.8, 1), 1)


func _physics_process(delta: float) -> void:
	if state in [S.HURT, S.DEAD, S.STAGGER]:
		super._physics_process(delta)
		queue_redraw()
		return
	_t += delta
	velocity.y = minf(velocity.y + GRAVITY * delta, 540.0)
	var p := _player()
	var offset := p.position - position if p else Vector2(9999, 9999)
	var sees := p and p.state != Player.S.DEAD and absf(offset.x) < 300 and absf(offset.y) < 60
	if sees:
		var ray := PhysicsRayQueryParameters2D.create(position + Vector2(0, -30), p.position + Vector2(0, -30), 1)
		sees = get_world_2d().direct_space_state.intersect_ray(ray).is_empty()
	_tell.visible = state == S.WINDUP
	_eyes.energy = 0.5 + (_t / DRAW_TIME if state == S.WINDUP else 0.0)
	velocity.x = 0
	match state:
		S.PATROL, S.CHASE:
			Sprites.play(sprite, "idle")
			if sees:
				_set_facing(offset.x)
				if absf(offset.x) < 100:
					# Check the retreat direction rather than walking backwards into a pit.
					var floor_cell := level.cell_of(position + Vector2(-facing * 18, 4))
					if level.is_floor(floor_cell.x, floor_cell.y) and not is_on_wall():
						velocity.x = -facing * 48
				if _t > 0.8:
					_enter(S.WINDUP)
		S.WINDUP:
			Sprites.play(sprite, "block", ["idle"])
			if _t >= DRAW_TIME:
				var bolt := ShadowBolt.new()
				bolt.level = level
				bolt.archer = self
				bolt.position = position + Vector2(facing * 22, -30)
				bolt.velocity = Vector2(facing * 140, 0)
				level.add_child(bolt)
				_enter(S.RECOVER)
		S.RECOVER:
			Sprites.play(sprite, "idle")
			if _t > 0.8:
				_enter(S.CHASE)
	move_and_slide()
	queue_redraw()
