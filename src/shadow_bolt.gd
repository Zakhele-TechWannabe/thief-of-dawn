class_name ShadowBolt
extends Area2D
## Slow, readable projectile. Uses Kael's normal roll immunity and front-facing parry window.

var level: Level
var archer: Shade
var velocity := Vector2.ZERO
var reflected := false
var _age := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0
	shape.shape = circle
	add_child(shape)
	var light := Fx.light(Color(0.65, 0.35, 1), 0.6, 28)
	add_child(light)
	body_entered.connect(_hit)


func _draw() -> void:
	var color := Color(0.7, 0.9, 1) if reflected else Color(0.75, 0.4, 1)
	draw_line(-velocity.normalized() * 17, Vector2.ZERO, Color(color, 0.5), 3)
	draw_circle(Vector2.ZERO, 4, color)
	draw_circle(Vector2.ZERO, 2, Color.WHITE)


func _physics_process(delta: float) -> void:
	_age += delta
	var next := position + velocity * delta
	var query := PhysicsRayQueryParameters2D.create(global_position, next, 1)
	if _age > 6.0 or not get_world_2d().direct_space_state.intersect_ray(query).is_empty():
		queue_free()
		return
	position = next
	queue_redraw()


func _hit(body: Node2D) -> void:
	if body is Player and not reflected:
		var result: String = body.receive_attack(1, self)
		if result == "parried":
			reflected = true
			set_deferred("collision_mask", 4)
			var target := archer.global_position + Vector2(0, -26) if is_instance_valid(archer) else position - velocity
			velocity = (target - position).normalized() * 210.0
		elif result != "miss":
			queue_free()
	elif reflected and body.has_method("take_hit"):
		body.take_hit(2, signf(velocity.x) * 180.0, self)
		queue_free()
