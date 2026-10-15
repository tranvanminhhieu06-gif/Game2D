class_name Hurtbox
extends Area2D
## Vùng nhận đòn. Đòn đánh gọi receive_hit(), chủ thể lắng nghe tín hiệu hit_received.

signal hit_received(damage: float, knockback: Vector2, source: Node)


## True khi chủ thể (node cha) đang bất tử, ví dụ đang lướt né: đòn đánh bỏ qua vùng này.
func is_invulnerable() -> bool:
	var target := get_parent()
	return target != null and target.has_method(&"is_invincible") and target.is_invincible()


func receive_hit(damage: float, knockback: Vector2, source: Node) -> void:
	hit_received.emit(damage, knockback, source)
