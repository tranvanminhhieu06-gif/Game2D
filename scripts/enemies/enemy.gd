class_name Enemy
extends CharacterBody2D
## Quái thường điều khiển bằng FSM 4 trạng thái (GDD mục 2.3):
## Tuần tra → Truy đuổi → Tấn công (có cảnh báo trước), và Khựng đòn khi trúng đòn nặng.
## Chỉ số lấy từ EnemyStats. Có projectile_scene thì là quái bắn xa: giữ khoảng cách và bắn đạn.

signal died
signal health_changed(current: float, maximum: float)

enum State { PATROL, CHASE, ATTACK, STAGGER, DEAD }
enum AttackPhase { TELEGRAPH, ACTIVE, RECOVERY }

## Gia tốc khi đổi hướng/tốc độ (px/giây²).
const ACCELERATION := 1200.0
## Lực hãm khi bị đẩy lùi hoặc đứng ra đòn (px/giây²).
const KNOCKBACK_FRICTION := 1400.0
## Bề ngang vạch cảnh báo hướng bắn của quái bắn xa.
const AIM_LINE_WIDTH := 12.0
## Màu vùng cảnh báo khi đang gồng đòn và lúc đòn có hiệu lực.
const TELEGRAPH_COLOR := Color(1, 0.15, 0.1, 0.15)
const STRIKE_COLOR := Color(1, 0.3, 0.2, 0.7)

@export var stats: EnemyStats

var health := 0.0
## Tâm vùng tuần tra, lấy theo vị trí lúc xuất hiện.
var home_position := Vector2.ZERO

var _state := State.PATROL
var _target: Node2D
var _facing := Vector2.DOWN
## Thời gian còn lại của trạng thái hoặc pha hiện tại.
var _state_time := 0.0
var _patrol_point := Vector2.ZERO
var _patrol_waiting := true
var _attack_phase := AttackPhase.TELEGRAPH
var _attack_cooldown_left := 0.0
var _flash_tween: Tween

@onready var _visual: Node2D = $Visual
@onready var _body: Polygon2D = $Visual/Body
@onready var _facing_arrow: Node2D = $Visual/FacingArrow
@onready var _health_bar: Node2D = $HealthBar
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _attack_pivot: Node2D = $AttackPivot
@onready var _hitbox: Hitbox = $AttackPivot/AttackHitbox
@onready var _telegraph: Polygon2D = $AttackPivot/Telegraph


func _ready() -> void:
	if stats == null:
		push_error("Enemy %s: chưa gán EnemyStats." % name)
		set_physics_process(false)
		return
	home_position = global_position
	health = stats.max_hp
	_body.color = stats.color
	if stats.is_ranged():
		# Vạch ngắm dài bằng tầm bay của đạn.
		var half := AIM_LINE_WIDTH / 2.0
		var length := stats.projectile_range
		_telegraph.polygon = PackedVector2Array(
			[Vector2(0, -half), Vector2(length, -half), Vector2(length, half), Vector2(0, half)]
		)
	else:
		_hitbox.configure(stats.attack_hitbox_size, stats.attack_reach)
		_telegraph.polygon = _hitbox.get_polygon()
	_telegraph.visible = false
	_hurtbox.hit_received.connect(_on_hit_received)
	_target = get_tree().get_first_node_in_group(&"player") as Node2D
	_enter_patrol_wait()


func _physics_process(delta: float) -> void:
	_attack_cooldown_left = maxf(_attack_cooldown_left - delta, 0.0)
	match _state:
		State.PATROL:
			_process_patrol(delta)
		State.CHASE:
			_process_chase(delta)
		State.ATTACK:
			_process_attack(delta)
		State.STAGGER:
			_process_stagger(delta)
		State.DEAD:
			return
	move_and_slide()


func _distance_to_target() -> float:
	if _target == null or not is_instance_valid(_target):
		return INF
	return global_position.distance_to(_target.global_position)


# --- Tuần tra ---


func _process_patrol(delta: float) -> void:
	if _distance_to_target() <= stats.aggro_range:
		_state = State.CHASE
		return
	_state_time -= delta
	if _patrol_waiting:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)
		if _state_time <= 0.0:
			var offset := Vector2.from_angle(randf() * TAU) * randf_range(0.3, 1.0)
			_walk_to(home_position + offset * stats.patrol_radius)
		return
	var to_point := _patrol_point - global_position
	# Tới nơi, hoặc bị kẹt quá lâu, thì đứng nghỉ rồi chọn điểm mới.
	if to_point.length() < 6.0 or _state_time <= 0.0:
		_enter_patrol_wait()
	else:
		_move_in_direction(to_point.normalized(), stats.move_speed, delta)


func _enter_patrol_wait() -> void:
	_patrol_waiting = true
	_state_time = randf_range(1.0, 2.5)


func _walk_to(point: Vector2) -> void:
	_patrol_point = point
	_patrol_waiting = false
	_state_time = 6.0


# --- Truy đuổi ---


func _process_chase(delta: float) -> void:
	var distance := _distance_to_target()
	if distance > stats.lose_aggro_range:
		# Mất dấu: quay về điểm xuất hiện rồi tuần tra tiếp.
		_state = State.PATROL
		_walk_to(home_position)
		return
	var to_target := _target.global_position - global_position
	if distance > stats.attack_range:
		_move_in_direction(to_target.normalized(), stats.chase_speed, delta)
		return
	_face(to_target)
	if _attack_cooldown_left <= 0.0:
		velocity = Vector2.ZERO
		_start_attack()
	elif stats.is_ranged() and distance < stats.keep_away_range:
		# Quái bắn xa lùi lại giữ khoảng cách trong lúc chờ bắn tiếp.
		var away := -to_target.normalized() * stats.move_speed
		velocity = velocity.move_toward(away, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)


func _move_in_direction(direction: Vector2, speed: float, delta: float) -> void:
	velocity = velocity.move_toward(direction * speed, ACCELERATION * delta)
	_face(direction)


func _face(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		_facing = direction.normalized()
		_facing_arrow.rotation = _facing.angle()


# --- Tấn công ---


func _start_attack() -> void:
	_state = State.ATTACK
	# Khóa hướng ngay từ lúc cảnh báo để người chơi có thể né.
	_attack_pivot.rotation = _facing.angle()
	_hitbox.start_swing(stats.attack_power, _facing * stats.attack_knockback, self)
	_enter_attack_phase(AttackPhase.TELEGRAPH)


func _process_attack(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	if _attack_phase == AttackPhase.ACTIVE and not stats.is_ranged():
		_hitbox.apply_hits()
	_state_time -= delta
	if _attack_phase == AttackPhase.TELEGRAPH:
		# Vùng cảnh báo đậm dần cho tới lúc ra đòn.
		var progress := 1.0 - _state_time / stats.telegraph_time
		_telegraph.color.a = lerpf(TELEGRAPH_COLOR.a, 0.45, clampf(progress, 0.0, 1.0))
	if _state_time > 0.0:
		return
	match _attack_phase:
		AttackPhase.TELEGRAPH:
			velocity = _facing * stats.attack_lunge_speed
			if stats.is_ranged():
				_fire_projectile()
			_enter_attack_phase(AttackPhase.ACTIVE)
		AttackPhase.ACTIVE:
			_enter_attack_phase(AttackPhase.RECOVERY)
		AttackPhase.RECOVERY:
			_attack_cooldown_left = stats.attack_cooldown
			_state = State.CHASE


func _enter_attack_phase(phase: AttackPhase) -> void:
	_attack_phase = phase
	match phase:
		AttackPhase.TELEGRAPH:
			_state_time = stats.telegraph_time
			_telegraph.color = TELEGRAPH_COLOR
			_telegraph.visible = true
		AttackPhase.ACTIVE:
			_state_time = stats.attack_active_time
			_telegraph.color = STRIKE_COLOR
		AttackPhase.RECOVERY:
			_state_time = stats.attack_recovery_time
			_telegraph.visible = false


func _fire_projectile() -> void:
	var projectile := stats.projectile_scene.instantiate() as Projectile
	projectile.direction = _facing
	projectile.speed = stats.projectile_speed
	projectile.max_distance = stats.projectile_range
	projectile.damage = stats.attack_power
	projectile.knockback = stats.attack_knockback
	projectile.source = self
	# Gắn vào node cha để đạn không bay theo quái.
	get_parent().add_child(projectile)
	projectile.global_position = _attack_pivot.global_position


# --- Nhận đòn, khựng, chết ---


func _on_hit_received(damage: float, knockback: Vector2, _source: Node) -> void:
	if _state == State.DEAD:
		return
	var final_damage := DamageFormula.mitigate(damage, stats.defense)
	_set_health(health - final_damage)
	var offset := Vector2(randf_range(-10.0, 10.0), -60.0)
	DamageNumber.spawn(get_parent(), global_position + offset, final_damage)
	velocity = knockback
	if health <= 0.0:
		_die()
		return
	_flash()
	if knockback.length() >= stats.stagger_knockback:
		_enter_stagger()
	elif _state == State.PATROL:
		# Bị đánh lén thì quay sang truy đuổi ngay.
		_state = State.CHASE


func _enter_stagger() -> void:
	# Đòn nặng ngắt cả đòn đang gồng.
	_state = State.STAGGER
	_state_time = stats.stagger_time
	_telegraph.visible = false


func _process_stagger(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	_state_time -= delta
	if _state_time <= 0.0:
		_state = State.CHASE


func _set_health(value: float) -> void:
	health = clampf(value, 0.0, stats.max_hp)
	_health_bar.ratio = health / stats.max_hp
	health_changed.emit(health, stats.max_hp)


func _flash() -> void:
	if _flash_tween:
		_flash_tween.kill()
	_visual.modulate = Color(2.5, 2.5, 2.5)
	_flash_tween = create_tween()
	_flash_tween.tween_property(_visual, "modulate", Color.WHITE, 0.15)


func _die() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO
	_telegraph.visible = false
	_health_bar.visible = false
	collision_layer = 0
	collision_mask = 0
	_hurtbox.set_deferred(&"monitorable", false)
	if _flash_tween:
		_flash_tween.kill()
	_visual.modulate = Color.WHITE
	died.emit()
	var tween := create_tween()
	tween.tween_property(_visual, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
