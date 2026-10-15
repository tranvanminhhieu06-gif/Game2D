class_name DamageNumber
extends Label
## Số sát thương bay lên rồi mờ dần (Floating Damage Text).

const RISE := 36.0
const DURATION := 0.6
const BOX_SIZE := Vector2(80, 24)


static func spawn(parent: Node, world_position: Vector2, amount: float) -> DamageNumber:
	var number := DamageNumber.new()
	number.text = str(roundi(amount))
	parent.add_child(number)
	number.size = BOX_SIZE
	number.global_position = world_position - BOX_SIZE / 2.0
	return number


func _ready() -> void:
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", 20)
	add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	add_theme_color_override("font_outline_color", Color.BLACK)
	add_theme_constant_override("outline_size", 4)
	var tween := create_tween().set_parallel()
	var rise := tween.tween_property(self, "position:y", -RISE, DURATION).as_relative()
	rise.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, DURATION * 0.5).set_delay(DURATION * 0.5)
	tween.chain().tween_callback(queue_free)
