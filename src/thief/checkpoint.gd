class_name ThiefCheckpoint
extends RefCounted
## Full stage snapshot, separate from StoryState's committed decisions.
var data := {}
func capture(level: Node2D, spawn: Vector2) -> void:
	var guards := []
	for g in level.guards:
		guards.append([g.position, g.state, g.facing, g.suspicion, g.last_known, g.waypoint, g.timer, g.off_balance])
	var items := []
	for item in level.interactables:
		items.append(item.used)
	data = {"spawn": spawn, "guards": guards, "items": items, "flags": level.flags.duplicate(true),
		"tools": level.renn.tools.duplicate(), "carried": level.renn.carried}
func restore(level: Node2D) -> void:
	if data.is_empty():
		return
	for i in level.guards.size():
		var g: WatchGuard = level.guards[i]
		var s: Array = data.guards[i]
		g.position = s[0]
		g.state = s[1]
		g.facing = s[2]
		g.suspicion = s[3]
		g.last_known = s[4]
		g.waypoint = s[5]
		g.timer = s[6]
		g.off_balance = s[7]
		g.velocity = Vector2.ZERO
		g.bark_time = 0
	for i in level.interactables.size():
		var item: ThiefInteractable = level.interactables[i]
		item.used = data.items[i]
		item.progress = 0
		item.set_open(item.used)
	level.flags = data.flags.duplicate(true)
	level.renn.position = data.spawn
	level.renn.velocity = Vector2.ZERO
	level.renn.tools.assign(data.tools)
	level.renn.carried = data.carried
	level.renn.break_used = false
	level.renn.grace = 2
	level.renn.slide = 0
	level.renn._enter(RennController.S.MOVE)
	level.renn._show_ledge_sprite("")
	level.stealing = false
	for pebble in level.get_tree().get_nodes_in_group("slice_pebbles"):
		pebble.queue_free()
