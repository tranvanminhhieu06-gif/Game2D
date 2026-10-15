@tool
class_name GreyboxBlock
extends StaticBody2D
## Khối chắn dùng cho bản xám: va chạm theo mặt đáy (footprint),
## vẽ giả khối nổi để kiểm tra Y-sort. Gốc tọa độ là mép dưới, giữa của mặt đáy.

@export var footprint := Vector2(64, 32):
	set(value):
		footprint = Vector2(maxf(value.x, 1.0), maxf(value.y, 1.0))
		_refresh()
## Chiều cao phần vẽ nổi lên trên mặt đáy (chỉ là hình ảnh, không ảnh hưởng va chạm).
@export var height: float = 64.0:
	set(value):
		height = maxf(value, 0.0)
		queue_redraw()
@export var color := Color(0.42, 0.44, 0.5):
	set(value):
		color = value
		queue_redraw()

var _shape := RectangleShape2D.new()
var _collision := CollisionShape2D.new()


func _ready() -> void:
	_collision.shape = _shape
	# INTERNAL: không bị lưu vào file .tscn, mỗi khối luôn tự sinh shape riêng.
	add_child(_collision, false, Node.INTERNAL_MODE_FRONT)
	_refresh()


func _refresh() -> void:
	_shape.size = footprint
	_collision.position = Vector2(0, -footprint.y / 2.0)
	queue_redraw()


func _draw() -> void:
	var left := -footprint.x / 2.0
	var front := Rect2(left, -height, footprint.x, height)
	var top := Rect2(left, -footprint.y - height, footprint.x, footprint.y)
	draw_rect(front, color.darkened(0.25))
	draw_rect(top, color.lightened(0.15))
	draw_rect(front.merge(top), color.darkened(0.6), false, 2.0)
