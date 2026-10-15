class_name Player
extends CharacterBody2D
## Nhân vật người chơi – bản xám (greybox).
## Có di chuyển top-down 8 hướng (gia tốc/hãm) và Lướt né (Dash) tốn Thể Lực.
## Gốc tọa độ (origin) đặt ở chân nhân vật để Y-sort đúng.

signal facing_changed(new_facing: Facing)
signal stamina_changed(current: float, maximum: float)
signal dashed(direction: Vector2)

## Hướng nhìn rời rạc theo chiều kim đồng hồ, bắt đầu từ hướng Đông.
## Sau này dùng để chọn animation 8 hướng.
enum Facing { E, SE, S, SW, W, NW, N, NE }

@export_group("Di chuyển")
## Tốc độ tối đa (px/giây). GDD chưa quy định, chỉnh khi thử cảm giác.
@export var max_speed: float = 220.0
## Gia tốc khi có input (px/giây²).
@export var acceleration: float = 1800.0
## Lực hãm khi thả input (px/giây²).
@export var friction: float = 2400.0

@export_group("Lướt né (Dash)")
## Tốc độ khi lướt (px/giây). Quãng lướt ≈ dash_speed × dash_duration.
@export var dash_speed: float = 650.0
@export var dash_duration: float = 0.18
## Thời gian bất tử tính từ lúc bắt đầu lướt (GDD: 0.25 giây).
@export var dash_invincibility: float = 0.25
## GDD: mỗi lần lướt tốn 25 Thể Lực.
@export var dash_stamina_cost: float = 25.0

@export_group("Thể Lực (Stamina)")
## GDD: mặc định 100 điểm.
@export var max_stamina: float = 100.0
## GDD: hồi 15 điểm/giây.
@export var stamina_regen: float = 15.0

var facing: Facing = Facing.S
var facing_vector: Vector2 = Vector2.DOWN
var stamina: float = 100.0

var _dash_direction := Vector2.ZERO
var _dash_time_left := 0.0
var _invincible_time_left := 0.0

@onready var _visual: Node2D = $Visual
@onready var _facing_arrow: Node2D = $Visual/FacingArrow


func _ready() -> void:
	stamina = max_stamina
	_facing_arrow.rotation = facing_vector.angle()


func _physics_process(delta: float) -> void:
	_invincible_time_left = maxf(_invincible_time_left - delta, 0.0)
	# get_vector đã áp deadzone và giới hạn độ dài ≤ 1 nên đi chéo không nhanh hơn.
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

	if is_dashing():
		_dash_time_left -= delta
		# Hết lướt thì giữ tốc độ chạy theo hướng lướt để chuyển tiếp mượt.
		var speed := dash_speed if is_dashing() else max_speed
		velocity = _dash_direction * speed
	else:
		_regen_stamina(delta)
		if Input.is_action_just_pressed(&"dash") and stamina >= dash_stamina_cost:
			_start_dash(input_dir)
		elif input_dir != Vector2.ZERO:
			velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
			_update_facing(input_dir)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
	# Phản hồi tạm cho khung bất tử, thay bằng VFX khi có art.
	_visual.modulate.a = 0.5 if is_invincible() else 1.0


func is_dashing() -> bool:
	return _dash_time_left > 0.0


## Hurtbox sau này kiểm tra hàm này để bỏ qua sát thương trong khung bất tử.
func is_invincible() -> bool:
	return _invincible_time_left > 0.0


func _start_dash(input_dir: Vector2) -> void:
	# Không bấm hướng thì lướt theo hướng đang nhìn.
	_dash_direction = input_dir.normalized() if input_dir != Vector2.ZERO else facing_vector
	_update_facing(_dash_direction)
	_set_stamina(stamina - dash_stamina_cost)
	_dash_time_left = dash_duration
	_invincible_time_left = dash_invincibility
	velocity = _dash_direction * dash_speed
	dashed.emit(_dash_direction)


func _regen_stamina(delta: float) -> void:
	if stamina < max_stamina:
		_set_stamina(stamina + stamina_regen * delta)


func _set_stamina(value: float) -> void:
	stamina = clampf(value, 0.0, max_stamina)
	stamina_changed.emit(stamina, max_stamina)


func _update_facing(direction: Vector2) -> void:
	facing_vector = direction.normalized()
	_facing_arrow.rotation = facing_vector.angle()
	var new_facing := wrapi(roundi(facing_vector.angle() / (TAU / 8.0)), 0, 8) as Facing
	if new_facing != facing:
		facing = new_facing
		facing_changed.emit(facing)
