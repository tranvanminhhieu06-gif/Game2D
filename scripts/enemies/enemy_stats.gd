class_name EnemyStats
extends Resource
## Chỉ số và hành vi của một loại quái (data-driven, GDD mục 6.1).
## Khoảng cách tính bằng px, quy ước 1 m = 32 px. Thời gian tính bằng giây.

@export var display_name := "Quái"
## Màu khối tạm cho bản xám, bỏ khi có sprite.
@export var color := Color(0.8, 0.4, 0.2)

@export_group("Chỉ số")
@export var max_hp := 100.0
@export var defense := 10.0
@export var attack_power := 15.0

@export_group("Di chuyển")
## Tốc độ khi tuần tra (px/giây).
@export var move_speed := 60.0
## Tốc độ khi truy đuổi (px/giây).
@export var chase_speed := 130.0
## GDD: tuần tra quanh điểm xuất hiện trong bán kính 5 m.
@export var patrol_radius := 160.0
## GDD: phát hiện người chơi trong 8 m.
@export var aggro_range := 256.0
## Người chơi ra xa hơn khoảng này thì bỏ đuổi, quay về điểm xuất hiện.
@export var lose_aggro_range := 400.0

@export_group("Tấn công")
## Vào trong khoảng này (tính từ chân tới chân) thì bắt đầu ra đòn.
@export var attack_range := 40.0
## GDD: khóa hướng và dừng cảnh báo 0.4 giây trước khi ra đòn.
@export var telegraph_time := 0.4
@export var attack_active_time := 0.12
@export var attack_recovery_time := 0.45
## Thời gian nghỉ giữa hai lần tấn công.
@export var attack_cooldown := 0.8
@export var attack_lunge_speed := 160.0
@export var attack_knockback := 160.0
@export var attack_reach := 26.0
@export var attack_hitbox_size := Vector2(40, 32)

@export_group("Khựng đòn (Stagger)")
## Đòn có lực đẩy lùi từ mức này trở lên được tính là đòn nặng, gây khựng.
@export var stagger_knockback := 200.0
@export var stagger_time := 0.5
