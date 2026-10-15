@tool
extends Node2D
## Nền lưới cho bản xám, giúp nhìn rõ tốc độ di chuyển và khoảng cách.

@export var size := Vector2(2560, 1600):
	set(value):
		size = value
		queue_redraw()
@export var cell_size: float = 64.0:
	set(value):
		cell_size = maxf(value, 8.0)
		queue_redraw()
@export var base_color := Color(0.2, 0.24, 0.2):
	set(value):
		base_color = value
		queue_redraw()
@export var line_color := Color(1, 1, 1, 0.06):
	set(value):
		line_color = value
		queue_redraw()


func _draw() -> void:
	var area := Rect2(-size / 2.0, size)
	draw_rect(area, base_color)
	var x := area.position.x
	while x <= area.end.x:
		draw_line(Vector2(x, area.position.y), Vector2(x, area.end.y), line_color)
		x += cell_size
	var y := area.position.y
	while y <= area.end.y:
		draw_line(Vector2(area.position.x, y), Vector2(area.end.x, y), line_color)
		y += cell_size
