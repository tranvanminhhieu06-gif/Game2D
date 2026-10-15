class_name Player
extends CharacterBody2D
## Nhân vật người chơi – bản xám (greybox).
## Hiện chỉ có di chuyển top-down 8 hướng có gia tốc/hãm.
## Gốc tọa độ (origin) đặt ở chân nhân vật để Y-sort đúng.

signal facing_changed(new_facing: Facing)

## Hướng nhìn rời rạc theo chiều kim đồng hồ, bắt đầu từ hướng Đông.
## Sau này dùng để chọn animation 8 hướng.
enum Facing { E, SE, S, SW, W, NW, N, NE }

## Tốc độ tối đa (px/giây). GDD chưa quy định, chỉnh khi thử cảm giác.
@export var max_speed: float = 220.0
## Gia tốc khi có input (px/giây²).
@export var acceleration: float = 1800.0
## Lực hãm khi thả input (px/giây²).
@export var friction: float = 2400.0

var facing: Facing = Facing.S
var facing_vector: Vector2 = Vector2.DOWN

@onready var _facing_arrow: Node2D = $Visual/FacingArrow


func _ready() -> void:
	_facing_arrow.rotation = facing_vector.angle()


func _physics_process(delta: float) -> void:
	# get_vector đã áp deadzone và giới hạn độ dài ≤ 1 nên đi chéo không nhanh hơn.
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
		_update_facing(input_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()


func _update_facing(direction: Vector2) -> void:
	facing_vector = direction.normalized()
	_facing_arrow.rotation = facing_vector.angle()
	var new_facing := wrapi(roundi(facing_vector.angle() / (TAU / 8.0)), 0, 8) as Facing
	if new_facing != facing:
		facing = new_facing
		facing_changed.emit(facing)
