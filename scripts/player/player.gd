class_name Player
extends CharacterBody2D
## Nhân vật người chơi – bản xám (greybox).
## Có di chuyển top-down 8 hướng, Lướt né (Dash) tốn Thể Lực
## đánh thường 3 nhịp (Tam Liên Kích) và nhận sát thương (hồi sinh tại chỗ xuất phát khi hết máu).
## Gốc tọa độ (origin) đặt ở chân nhân vật để Y-sort đúng.

signal facing_changed(new_facing: Facing)
signal stamina_changed(current: float, maximum: float)
signal dashed(direction: Vector2)
signal attack_started(combo_index: int)
signal health_changed(current: float, maximum: float)
signal died

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

@export_group("Sinh Lực & Phòng thủ")
## HP cấp 1 theo GDD: HP(L) = 200 + 45 × (L - 1).
@export var max_health: float = 200.0
## GDD chưa cho DEF gốc cấp 1, tạm đặt 10.
@export var defense: float = 10.0
## Thời gian bất tử ngắn sau khi trúng đòn, tránh bị nhiều đòn dồn cùng lúc.
@export var hurt_invincibility: float = 0.4

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
var health: float = 200.0

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
## Nơi hồi sinh khi hết máu (bản xám; GDD: Miếu Thổ Thần gần nhất).
var _respawn_position := Vector2.ZERO
var _hurt_tween: Tween

@onready var _visual: Node2D = $Visual
@onready var _body: Node2D = $Visual/Body
@onready var _camera: Camera2D = $Camera2D
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _facing_arrow: Node2D = $Visual/FacingArrow
@onready var _attack_pivot: Node2D = $AttackPivot
@onready var _attack_hitbox: Hitbox = $AttackPivot/AttackHitbox
@onready var _attack_visual: Polygon2D = $AttackPivot/AttackVisual


func _ready() -> void:
	add_to_group(&"player")
	stamina = max_stamina
	health = max_health
	_respawn_position = global_position
	_hurtbox.hit_received.connect(_on_hit_received)
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

	_attack_pivot.rotation = facing_vector.angle()
	_attack_hitbox.configure(_attack_step.hitbox_size, _attack_step.reach)
	_attack_hitbox.start_swing(
		attack_power * _attack_step.damage_multiplier, facing_vector * _attack_step.knockback, self
	)
	_attack_visual.polygon = _attack_hitbox.get_polygon()

	velocity = facing_vector * _attack_step.lunge_speed
	_enter_phase(AttackPhase.STARTUP)
	attack_started.emit(_combo_index)


func _process_attack(delta: float, input_dir: Vector2) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if Input.is_action_just_pressed(&"attack"):
		_attack_queued = true

	if _attack_phase == AttackPhase.ACTIVE:
		_attack_hitbox.apply_hits()
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


# --- Nhận sát thương ---


func _on_hit_received(damage: float, knockback: Vector2, _source: Node) -> void:
	# Khung bất tử của lướt né (và sau khi trúng đòn) bỏ qua mọi đòn.
	if is_invincible():
		return
	var final_damage := DamageFormula.mitigate(damage, defense)
	_set_health(health - final_damage)
	var offset := Vector2(randf_range(-10.0, 10.0), -60.0)
	DamageNumber.spawn(get_parent(), global_position + offset, final_damage, Color(1, 0.4, 0.35))
	if health <= 0.0:
		died.emit()
		_respawn()
		return
	velocity += knockback
	_invincible_time_left = maxf(_invincible_time_left, hurt_invincibility)
	if _hurt_tween:
		_hurt_tween.kill()
	_body.modulate = Color(1, 0.3, 0.3)
	_hurt_tween = create_tween()
	_hurt_tween.tween_property(_body, "modulate", Color.WHITE, 0.25)


func _respawn() -> void:
	global_position = _respawn_position
	velocity = Vector2.ZERO
	_state = State.MOVE
	_attack_visual.visible = false
	_combo_index = 0
	_combo_window_left = 0.0
	_set_health(max_health)
	_set_stamina(max_stamina)
	_invincible_time_left = 1.0
	_camera.reset_smoothing()


func _set_health(value: float) -> void:
	health = clampf(value, 0.0, max_health)
	health_changed.emit(health, max_health)


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
