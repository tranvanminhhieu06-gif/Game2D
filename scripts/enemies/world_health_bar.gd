extends Node2D
## Thanh máu nhỏ trên đầu quái (bản xám). Chỉ hiện khi đã mất máu.

@export var bar_size := Vector2(34, 4)
@export var fill_color := Color(0.8, 0.2, 0.18)

var ratio := 1.0:
	set(value):
		ratio = clampf(value, 0.0, 1.0)
		visible = ratio < 1.0
		queue_redraw()


func _ready() -> void:
	visible = false


func _draw() -> void:
	var origin := -bar_size / 2.0
	draw_rect(Rect2(origin - Vector2.ONE, bar_size + Vector2(2, 2)), Color(0, 0, 0, 0.7))
	draw_rect(Rect2(origin, Vector2(bar_size.x * ratio, bar_size.y)), fill_color)
