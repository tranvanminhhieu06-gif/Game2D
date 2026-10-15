extends ProgressBar
## Thanh Sinh Lực tạm cho bản xám (GDD: màu Đỏ Sơn Mài, góc trên bên trái).

@export var player: Player


func _ready() -> void:
	if player == null:
		push_warning("HealthBar: chưa gán Player.")
		return
	_on_health_changed(player.health, player.max_health)
	player.health_changed.connect(_on_health_changed)


func _on_health_changed(current: float, maximum: float) -> void:
	max_value = maximum
	value = current
