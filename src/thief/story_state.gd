extends Node
## Committed decisions survive retries and application restarts; local flags belong to checkpoints.
var chapter := 1
var year := 320
var flags := {}

func _ready() -> void:
	if FileAccess.file_exists("user://thief_story.json"):
		var data = JSON.parse_string(FileAccess.get_file_as_string("user://thief_story.json"))
		if data is Dictionary:
			flags = data

func commit(local_flags: Dictionary) -> void:
	flags.merge(local_flags, true)
	var file := FileAccess.open("user://thief_story.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(flags))
