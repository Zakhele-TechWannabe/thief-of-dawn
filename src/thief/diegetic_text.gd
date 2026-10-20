class_name DiegeticText
extends Node2D
## Fixed glyph vocabulary. No readable world writing is substituted by UI text.
const GLYPHS := [3, 5, 1, 6, 2, 4, 5, 3, 1, 2, 6, 4]
func _draw() -> void:
	draw_rect(Rect2(-20, -53, 40, 48), Color(.69, .62, .43))
	# Crossed shovel and pick: Renn's useful sketch interpretation.
	draw_line(Vector2(-12, -43), Vector2(10, -25), Color(.21, .22, .23), 2)
	draw_line(Vector2(12, -43), Vector2(-9, -25), Color(.21, .22, .23), 2)
	draw_rect(Rect2(-15, -46, 9, 6), Color(.28, .29, .3))
	draw_line(Vector2(7, -46), Vector2(17, -40), Color(.21, .22, .23), 2)
	for i in GLYPHS.size():
		var p := Vector2(-15 + (i % 6) * 5, -19 + (i / 6) * 7)
		draw_line(p, p + Vector2(0, 4), Color(.2, .19, .17))
		draw_line(p + Vector2(0, GLYPHS[i] % 3), p + Vector2(3, (GLYPHS[i] + 1) % 4), Color(.2, .19, .17))
