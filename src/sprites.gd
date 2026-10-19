class_name Sprites
## Builds SpriteFrames from assets/sprites/<actor>/<anim>/NN.png plus meta.json (see ASSETS.md).

static var _cache := {}


## Returns {"frames": SpriteFrames, "anchor": Vector2, "size": Vector2} or an empty dict if the actor is missing.
static func load_actor(actor: String) -> Dictionary:
	if _cache.has(actor):
		return _cache[actor]
	var root := "res://assets/sprites/%s" % actor
	var meta_path := root + "/meta.json"
	if not FileAccess.file_exists(meta_path):
		return {}
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for anim in meta["anims"]:
		var info: Dictionary = meta["anims"][anim]
		var textures: Array[Texture2D] = []
		for i in 32:
			var path := "%s/%s/%02d.png" % [root, anim, i]
			if not ResourceLoader.exists(path):
				break
			textures.append(load(path))
		if textures.is_empty():
			continue
		frames.add_animation(anim)
		frames.set_animation_speed(anim, float(info.get("fps", 10)))
		frames.set_animation_loop(anim, bool(info.get("loop", true)))
		for tex in textures:
			frames.add_frame(anim, tex)
	var result := {
		"frames": frames,
		"anchor": Vector2(meta["anchor"][0], meta["anchor"][1]),
		"size": Vector2(meta["frame_size"][0], meta["frame_size"][1]),
		"faces": -1.0 if meta.get("faces", "right") == "left" else 1.0,   # which way the art is drawn
	}
	_cache[actor] = result
	return result


## An AnimatedSprite2D whose origin is the actor's feet.
static func make(actor: String) -> AnimatedSprite2D:
	var data := load_actor(actor)
	var sprite := AnimatedSprite2D.new()
	if data.is_empty():
		return sprite
	sprite.sprite_frames = data["frames"]
	sprite.centered = false
	sprite.offset = -data["anchor"]
	return sprite


## Point the sprite toward `dir` (+1 right, -1 left), mirroring only when the art faces the other way,
## and keeping the feet on the origin (the anchor isn't always centred in the frame).
static func face(sprite: AnimatedSprite2D, actor: String, dir: float) -> void:
	var data := load_actor(actor)
	if data.is_empty() or dir == 0.0:
		return
	var flipped: bool = signf(dir) != data["faces"]
	sprite.flip_h = flipped
	sprite.offset.x = -(data["size"].x - data["anchor"].x) if flipped else -data["anchor"].x


## Play `anim`, falling back through `fallbacks` when the actor lacks it.
static func play(sprite: AnimatedSprite2D, anim: String, fallbacks: Array = []) -> void:
	if sprite.sprite_frames == null:
		return
	for name in [anim] + fallbacks:
		if sprite.sprite_frames.has_animation(name):
			if sprite.animation != name or not sprite.is_playing():
				sprite.play(name)
			return
