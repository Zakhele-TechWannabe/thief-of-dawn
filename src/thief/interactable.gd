class_name ThiefInteractable
extends Node2D
## Spatial hold interaction; transient progress is deliberately absent from checkpoint snapshots.
var kind := ""
var prompt := ""
var duration := 1.0
var progress := 0.0
var used := false
var gate: StaticBody2D
var level: Node2D

func work(delta: float, held: bool) -> void:
	if used:
		return
	if not held:
		progress = 0
		return
	if kind == "loot":
		level.stealing = true
		for guard in level.guards:
			if guard.can_see(level.renn):
				guard.last_known = level.renn.position
				guard.suspicion = 1
				guard.enter(WatchGuard.S.CHASE)
	progress += delta * (1.6 if kind in ["vent", "drain"] and "pry hook" in level.renn.tools else 1.0)
	if progress >= duration:
		if kind == "loot" and level.renn.carried != "":
			level.say("Hands full. V drops what you're holding.")
			progress = 0
			return
		used = true
		match kind:
			"vent", "drain":
				level.flags["escape_route"] = kind
				set_open(true)
				level.noise(position, 150 if kind == "vent" else 75)
			"loot":
				level.renn.carried = "coin pouch"
				level.say("Renn: He'll sleep lighter now.", level.renn)
			"tool":
				if level.renn.tools.size() < 2:
					level.renn.tools.append("pry hook")
				else:
					used = false
			"pebbles":
				if "pebble" not in level.renn.tools and level.renn.tools.size() < 2:
					level.renn.tools.append("pebble")
				used = false
			"checkpoint":
				level.capture_checkpoint(position)
	queue_redraw()

func set_open(open: bool) -> void:
	if gate:
		gate.get_child(0).set_deferred("disabled", open)
	queue_redraw()

func _draw() -> void:
	if used and kind not in ["checkpoint", "vent", "drain"]:
		return
	match kind:
		"vent", "drain":
			for x in range(-12, 16, 6):
				draw_line(Vector2(x, -28), Vector2(x + (15 if used else 0), 0), Color(.48, .48, .46), 2)
		"loot":
			draw_rect(Rect2(-20, -20, 40, 5), Color(.4, .27, .17))
			draw_line(Vector2(-16, -15), Vector2(-16, 0), Color(.3, .22, .15), 3)
			draw_circle(Vector2(3, -25), 5, Color(.68, .49, .22))
		"checkpoint":
			draw_circle(Vector2(0, -10), 5, Color(.4, .7, .8))
		"tool":
			draw_polyline(PackedVector2Array([Vector2(-8, -8), Vector2(5, -16), Vector2(9, -12)]), Color(.65, .65, .68), 3)
		"pebbles":
			for x in 4:
				draw_circle(Vector2(x * 4 - 6, -3), 2, Color(.55, .57, .61))
