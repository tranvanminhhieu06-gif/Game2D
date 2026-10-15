class_name TrainingDummy
extends CharacterBody2D
## Hình nộm tập võ cho bản xám: nhận đòn, hiện số sát thương, bị đẩy lùi.
## Không có máu, đánh mãi không hỏng.

## Phòng thủ (DEF) để thử công thức giáp: 100 DEF = giảm 50% sát thương.
@export var defense: float = 0.0
## Lực hãm khi bị đẩy lùi (px/giây²).
@export var knockback_friction: float = 1600.0

var _flash_tween: Tween

@onready var _visual: Node2D = $Visual
@onready var _hurtbox: Hurtbox = $Hurtbox


func _ready() -> void:
	_hurtbox.hit_received.connect(_on_hit_received)


func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		move_and_slide()


func _on_hit_received(damage: float, knockback: Vector2, _source: Node) -> void:
	var final_damage := DamageFormula.mitigate(damage, defense)
	velocity = knockback
	_flash()
	var offset := Vector2(randf_range(-10.0, 10.0), -64.0)
	DamageNumber.spawn(get_parent(), global_position + offset, final_damage)


func _flash() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_visual.modulate = Color(2.5, 2.5, 2.5)
	_flash_tween = create_tween()
	_flash_tween.tween_property(_visual, "modulate", Color.WHITE, 0.15)
