extends CharacterBody2D
var level: Node2D
var age := 0.0
func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 2
	add_child(shape)
func _physics_process(delta: float) -> void:
	age += delta
	velocity.y += 800 * delta
	if move_and_collide(velocity * delta):
		level.noise(position, 340)
		level.say("Stone on stone.")
		queue_free()
	elif age > 4:
		queue_free()
func _draw() -> void:
	draw_circle(Vector2.ZERO, 2, Color(.7, .7, .75))
