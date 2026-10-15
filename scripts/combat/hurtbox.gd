class_name Hurtbox
extends Area2D
## Vùng nhận đòn. Đòn đánh gọi receive_hit(), chủ thể lắng nghe tín hiệu hit_received.

signal hit_received(damage: float, knockback: Vector2, source: Node)


func receive_hit(damage: float, knockback: Vector2, source: Node) -> void:
	hit_received.emit(damage, knockback, source)
