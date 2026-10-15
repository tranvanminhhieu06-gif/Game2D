class_name Projectile
extends Area2D
## Đạn bay thẳng: trúng Hurtbox thì gây sát thương, chạm tường hoặc bay hết tầm thì tan.
## Mục tiêu đang bất tử (lướt né) thì đạn bay xuyên qua.

var direction := Vector2.RIGHT
var speed := 240.0
var max_distance := 360.0
var damage := 10.0
var knockback := 80.0
var source: Node

var _traveled := 0.0
var _spent := false


func _ready() -> void:
	rotation = direction.angle()
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	var step := speed * delta
	global_position += direction * step
	_traveled += step
	if _traveled >= max_distance:
		_vanish()


func _on_area_entered(area: Area2D) -> void:
	if _spent or not (area is Hurtbox):
		return
	var hurtbox := area as Hurtbox
	if hurtbox.is_invulnerable():
		return
	hurtbox.receive_hit(damage, direction * knockback, source)
	_vanish()


func _on_body_entered(body: Node2D) -> void:
	# Chỉ tường/vật cản tĩnh chặn đạn; thân nhân vật thì để Hurtbox xử lý.
	if body is StaticBody2D:
		_vanish()


func _vanish() -> void:
	if _spent:
		return
	_spent = true
	set_physics_process(false)
	set_deferred(&"monitoring", false)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(queue_free)
