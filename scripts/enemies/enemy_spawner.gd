class_name EnemySpawner
extends Marker2D
## Điểm xuất hiện quái: sinh quái làm con, quái chết thì sinh lại sau respawn_delay.
## Vị trí của spawner cũng là tâm vùng tuần tra của quái.

@export var enemy_scene: PackedScene
@export var stats: EnemyStats
## Đặt số âm để không sinh lại.
@export var respawn_delay: float = 5.0


func _ready() -> void:
	y_sort_enabled = true
	_spawn.call_deferred()


func _spawn() -> void:
	if enemy_scene == null or stats == null:
		push_warning("EnemySpawner %s: thiếu enemy_scene hoặc stats." % name)
		return
	var enemy := enemy_scene.instantiate() as Enemy
	enemy.stats = stats
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)


func _on_enemy_died() -> void:
	if respawn_delay >= 0.0:
		get_tree().create_timer(respawn_delay).timeout.connect(_spawn)
