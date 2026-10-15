class_name Player
extends CharacterBody2D
## Nhân vật người chơi – bản xám (greybox).
## Có di chuyển top-down 8 hướng, Lướt né (Dash) tốn Thể Lực
## và đánh thường 3 nhịp (Tam Liên Kích).
## Gốc tọa độ (origin) đặt ở chân nhân vật để Y-sort đúng.

signal facing_changed(new_facing: Facing)
signal stamina_changed(current: float, maximum: float)
signal dashed(direction: Vector2)
signal attack_started(combo_index: int)

## Hướng nhìn rời rạc theo chiều kim đồng hồ, bắt đầu từ hướng Đông.
## Sau này dùng để chọn animation 8 hướng.
enum Facing { E, SE, S, SW, W, NW, N, NE }
enum State { MOVE, DASH, ATTACK }
enum AttackPhase { STARTUP, ACTIVE, RECOVERY }

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

@export_group("Đánh thường (Tam Liên Kích)")
## ATK cấp 1 theo GDD: ATK(L) = 25 + 6 × (L - 1).
@export var attack_power: float = 25.0
## Các đòn trong chuỗi, mỗi đòn là một AttackStep (data/skills/).
@export var combo: Array[AttackStep] = []
## Sau khi thu đòn xong, bấm đánh trong khoảng này vẫn ra đòn kế tiếp.
@export var combo_window: float = 0.35

var facing: Facing = Facing.S
var facing_vector: Vector2 = Vector2.DOWN
var stamina: float = 100.0

var _state := State.MOVE

var _dash_direction := Vector2.ZERO
var _dash_time_left := 0.0
var _invincible_time_left := 0.0

## Chỉ số đòn đang ra (khi ATTACK) hoặc đòn sẽ ra tiếp theo (khi MOVE).
var _combo_index := 0
var _combo_window_left := 0.0
var _attack_step: AttackStep
var _attack_phase := AttackPhase.STARTUP
var _phase_time_left := 0.0
var _attack_queued := false
## Các Hurtbox đã trúng trong lần vung hiện tại, để mỗi đòn chỉ trúng một lần.
var _hit_this_swing := {}

@onready var _visual: Node2D = $Visual
@onready var _facing_arrow: Node2D = $Visual/FacingArrow
@onready var _attack_pivot: Node2D = $AttackPivot
@onready var _attack_hitbox: Area2D = $AttackPivot/AttackHitbox
@onready var _attack_shape: CollisionShape2D = $AttackPivot/AttackHitbox/CollisionShape2D
@onready var _attack_visual: Polygon2D = $AttackPivot/AttackVisual


func _ready() -> void:
	stamina = max_stamina
	_facing_arrow.rotation = facing_vector.angle()
	_attack_visual.visible = false


func _physics_process(delta: float) -> void:
	_invincible_time_left = maxf(_invincible_time_left - delta, 0.0)
	# get_vector đã áp deadzone và giới hạn độ dài ≤ 1 nên đi chéo không nhanh hơn.
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

	match _state:
		State.MOVE:
			_process_move(delta, input_dir)
		State.DASH:
			_process_dash(delta)
		State.ATTACK:
			_process_attack(delta, input_dir)

	if _state != State.DASH:
		_regen_stamina(delta)
	move_and_slide()
	# Phản hồi tạm cho khung bất tử, thay bằng VFX khi có art.
	_visual.modulate.a = 0.5 if is_invincible() else 1.0


func is_dashing() -> bool:
	return _state == State.DASH


func is_attacking() -> bool:
	return _state == State.ATTACK


## Hurtbox sau này kiểm tra hàm này để bỏ qua sát thương trong khung bất tử.
func is_invincible() -> bool:
	return _invincible_time_left > 0.0


# --- Di chuyển ---


func _process_move(delta: float, input_dir: Vector2) -> void:
	_combo_window_left = maxf(_combo_window_left - delta, 0.0)
	if _combo_window_left <= 0.0:
		_combo_index = 0

	if _try_dash(input_dir):
		return
	if Input.is_action_just_pressed(&"attack") and not combo.is_empty():
		_start_attack(input_dir)
		return

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
		_update_facing(input_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


# --- Lướt né ---


func _try_dash(input_dir: Vector2) -> bool:
	if not Input.is_action_just_pressed(&"dash") or stamina < dash_stamina_cost:
		return false
	# Không bấm hướng thì lướt theo hướng đang nhìn.
	_dash_direction = input_dir.normalized() if input_dir != Vector2.ZERO else facing_vector
	_update_facing(_dash_direction)
	_set_stamina(stamina - dash_stamina_cost)
	_dash_time_left = dash_duration
	_invincible_time_left = dash_invincibility
	velocity = _dash_direction * dash_speed
	_state = State.DASH
	dashed.emit(_dash_direction)
	return true


func _process_dash(delta: float) -> void:
	_dash_time_left -= delta
	if _dash_time_left > 0.0:
		velocity = _dash_direction * dash_speed
	else:
		# Hết lướt thì giữ tốc độ chạy theo hướng lướt để chuyển tiếp mượt.
		velocity = _dash_direction * max_speed
		_state = State.MOVE


# --- Đánh thường ---


func _start_attack(input_dir: Vector2) -> void:
	# Đang bấm hướng thì quay theo hướng đó trước khi đánh.
	if input_dir != Vector2.ZERO:
		_update_facing(input_dir)
	_attack_step = combo[_combo_index]
	_state = State.ATTACK
	_attack_queued = false
	_hit_this_swing.clear()

	_attack_pivot.rotation = facing_vector.angle()
	var shape := _attack_shape.shape as RectangleShape2D
	shape.size = _attack_step.hitbox_size
	_attack_shape.position = Vector2(_attack_step.reach, 0)
	var half := _attack_step.hitbox_size / 2.0
	var center := _attack_shape.position
	_attack_visual.polygon = PackedVector2Array(
		[
			center + Vector2(-half.x, -half.y),
			center + Vector2(half.x, -half.y),
			center + Vector2(half.x, half.y),
			center + Vector2(-half.x, half.y),
		]
	)

	velocity = facing_vector * _attack_step.lunge_speed
	_enter_phase(AttackPhase.STARTUP)
	attack_started.emit(_combo_index)


func _process_attack(delta: float, input_dir: Vector2) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if Input.is_action_just_pressed(&"attack"):
		_attack_queued = true

	if _attack_phase == AttackPhase.ACTIVE:
		_apply_hits()
	elif _attack_phase == AttackPhase.RECOVERY:
		# Lướt né hủy được phần thu đòn, chuỗi đánh quay về đòn đầu.
		if _try_dash(input_dir):
			_end_attack(false)
			return
		if _attack_queued and _combo_index + 1 < combo.size():
			_combo_index += 1
			_start_attack(input_dir)
			return

	_phase_time_left -= delta
	if _phase_time_left > 0.0:
		return
	match _attack_phase:
		AttackPhase.STARTUP:
			_enter_phase(AttackPhase.ACTIVE)
		AttackPhase.ACTIVE:
			_enter_phase(AttackPhase.RECOVERY)
		AttackPhase.RECOVERY:
			_state = State.MOVE
			_end_attack(true)


func _enter_phase(phase: AttackPhase) -> void:
	_attack_phase = phase
	match phase:
		AttackPhase.STARTUP:
			_phase_time_left = _attack_step.startup
		AttackPhase.ACTIVE:
			_phase_time_left = _attack_step.active
		AttackPhase.RECOVERY:
			_phase_time_left = _attack_step.recovery
	_attack_visual.visible = phase == AttackPhase.ACTIVE


## Kết thúc đòn đang ra. allow_follow_up = true thì vẫn giữ khoảng nối đòn.
func _end_attack(allow_follow_up: bool) -> void:
	_attack_visual.visible = false
	if allow_follow_up and _combo_index + 1 < combo.size():
		_combo_index += 1
		_combo_window_left = combo_window
	else:
		_combo_index = 0
		_combo_window_left = 0.0


func _apply_hits() -> void:
	for area in _attack_hitbox.get_overlapping_areas():
		if not (area is Hurtbox) or _hit_this_swing.has(area):
			continue
		_hit_this_swing[area] = true
		var damage := attack_power * _attack_step.damage_multiplier
		var knockback := facing_vector * _attack_step.knockback
		(area as Hurtbox).receive_hit(damage, knockback, self)


# --- Thể Lực & hướng nhìn ---


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
