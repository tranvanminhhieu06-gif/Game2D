class_name Hitbox
extends Area2D
## Vùng gây đòn hình chữ nhật đặt phía trước, xoay theo node cha (pivot).
## Gọi start_swing() mỗi lần vung, rồi apply_hits() mỗi khung trong pha trúng đòn:
## mỗi Hurtbox chỉ trúng một lần trong một lần vung.

var damage := 0.0
var knockback := Vector2.ZERO

var _source: Node
var _already_hit := {}

@onready var _shape_node: CollisionShape2D = $CollisionShape2D


func configure(size: Vector2, reach: float) -> void:
	(_shape_node.shape as RectangleShape2D).size = size
	_shape_node.position = Vector2(reach, 0)


## Đa giác bao vùng đánh, theo tọa độ của node cha. Dùng để vẽ cảnh báo/hiệu ứng tạm.
func get_polygon() -> PackedVector2Array:
	var half := (_shape_node.shape as RectangleShape2D).size / 2.0
	var center := position + _shape_node.position
	return PackedVector2Array(
		[
			center + Vector2(-half.x, -half.y),
			center + Vector2(half.x, -half.y),
			center + Vector2(half.x, half.y),
			center + Vector2(-half.x, half.y),
		]
	)


func start_swing(swing_damage: float, swing_knockback: Vector2, source: Node) -> void:
	damage = swing_damage
	knockback = swing_knockback
	_source = source
	_already_hit.clear()


func apply_hits() -> void:
	for area in get_overlapping_areas():
		if not (area is Hurtbox) or _already_hit.has(area):
			continue
		var hurtbox := area as Hurtbox
		# Mục tiêu đang bất tử thì chưa tính trúng: hết bất tử mà đòn còn hiệu lực vẫn trúng.
		if hurtbox.is_invulnerable():
			continue
		_already_hit[area] = true
		hurtbox.receive_hit(damage, knockback, _source)
