extends ProgressBar
## Thanh Thể Lực tạm cho bản xám (GDD: màu Vàng Đồng, góc trên bên trái).

@export var player: Player


func _ready() -> void:
	if player == null:
		push_warning("StaminaBar: chưa gán Player.")
		return
	_on_stamina_changed(player.stamina, player.max_stamina)
	player.stamina_changed.connect(_on_stamina_changed)


func _on_stamina_changed(current: float, maximum: float) -> void:
	max_value = maximum
	value = current
