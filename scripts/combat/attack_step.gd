class_name AttackStep
extends Resource
## Dữ liệu một đòn trong chuỗi đánh thường (data-driven theo GDD mục 6.1).
## Thời gian tính bằng giây, tốc độ bằng px/giây.

## Hệ số kỹ năng M_Skill (GDD: đánh thường = 1.0).
@export var damage_multiplier: float = 1.0
## Thời gian vung trước khi vùng đánh có hiệu lực.
@export var startup: float = 0.08
## Thời gian vùng đánh có hiệu lực.
@export var active: float = 0.1
## Thời gian thu đòn; trong lúc này có thể nối đòn kế tiếp hoặc lướt né để hủy.
@export var recovery: float = 0.22
## Tốc độ nhích người về phía trước khi ra đòn.
@export var lunge_speed: float = 120.0
## Tốc độ đẩy lùi mục tiêu trúng đòn.
@export var knockback: float = 60.0
## Khoảng cách từ thân tới tâm vùng đánh.
@export var reach: float = 30.0
## Kích thước vùng đánh (chiều dài theo hướng đánh × bề ngang).
@export var hitbox_size := Vector2(44, 36)
