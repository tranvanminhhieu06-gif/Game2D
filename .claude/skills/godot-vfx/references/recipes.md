# Công thức hiệu ứng 2D (Godot 4)

Mã dưới đây được viết theo cú pháp Godot 4 từ khai báo shader và code của các repo nguồn. **Chưa chạy thử trong Godot**; hãy chạy và xem kết quả trước khi báo hoàn thành. Đường dẫn `res://vfx/...` là ví dụ, thay theo `project-conventions.md`.

Chuẩn bị chung: chép shader cần dùng từ `assets/vfx_library/shaders/` hoặc `assets/gdquest-shaders/` vào `res://vfx/shaders/`.

## 1. Nháy trắng khi bị đánh (thay cho `VFX.flash_white`)

Shader: `flash_white.gdshader` (uniform `flash_amount` 0..1, `flash_color`).

```gdscript
@onready var sprite: Sprite2D = $Sprite2D
var _flash_mat: ShaderMaterial

func _ready() -> void:
	# Tạo material riêng cho từng thực thể để không nháy lây sang bản sao khác
	_flash_mat = ShaderMaterial.new()
	_flash_mat.shader = preload("res://vfx/shaders/flash_white.gdshader")
	sprite.material = _flash_mat

func hit_flash(duration: float = 0.12) -> void:
	_flash_mat.set_shader_parameter("flash_amount", 1.0)
	create_tween().tween_property(_flash_mat, "shader_parameter/flash_amount", 0.0, duration)
```

Nếu muốn gắn material trong editor, bật "Local to Scene" trên resource, nếu không mọi thực thể dùng chung một material và nháy cùng lúc.

## 2. Chết bằng dissolve

Shader: `dissolve.gdshader` (VL) cần `dissolve_texture`. Nếu để trắng mặc định thì không thấy hiệu ứng. Với `dissolve2D.gdshader` (GQ) cũng cần `dissolve_texture`.

```gdscript
static var _dissolve_noise: NoiseTexture2D  # tạo một lần, dùng chung

func die() -> void:
	if _dissolve_noise == null:
		_dissolve_noise = NoiseTexture2D.new()
		_dissolve_noise.noise = FastNoiseLite.new()
		await _dissolve_noise.changed  # NoiseTexture2D sinh ảnh bất đồng bộ
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://vfx/shaders/dissolve.gdshader")
	mat.set_shader_parameter("dissolve_texture", _dissolve_noise)
	mat.set_shader_parameter("edge_color", Color(1.0, 0.5, 0.0))
	sprite.material = mat
	var tw := create_tween()
	tw.tween_property(mat, "shader_parameter/dissolve_amount", 1.0, 0.6)
	await tw.finished
	queue_free()
```

Ở `dissolve_amount = 1.0` alpha về 0 hoàn toàn (theo công thức smoothstep trong shader).

## 3. Trạng thái (đóng băng, độc, cháy, hóa đá)

Mỗi shader có một uniform "lượng" từ 0 đến 1: `freeze_amount`, `poison_amount`, `burn_amount`, `petrify_amount`. Cần texture phụ: `frozen` cần `ice_texture`, `burning` cần `distortion_texture`, `petrify` cần `crack_texture`; `poison` thì không.

```gdscript
func set_status(mat: ShaderMaterial, param: String, on: bool, time: float = 0.25) -> void:
	create_tween().tween_property(mat, "shader_parameter/" + param, 1.0 if on else 0.0, time)

# set_status(status_mat, "freeze_amount", true)
```

Một sprite chỉ có một `material`. Nếu cần nhiều trạng thái cùng lúc, hoặc gộp vào một shader, hoặc dùng sprite phụ chồng lên, hoặc dùng `CanvasGroup`.

## 4. Phản hồi khi trúng đòn (kết hợp `VFX`)

Điều kiện: đã bật plugin `vfx_library` (autoload `VFX`) và cảnh có `Camera2D` active.

```gdscript
func take_hit(amount: int, is_crit: bool = false) -> void:
	hit_flash()  # công thức 1
	VFX.spawn_blood_splash(global_position)
	VFX.spawn_damage_number(global_position + Vector2(0, -30), amount, is_crit)
	if is_crit:
		VFX.critical_hit(global_position)  # đã gồm rung + đóng băng khung hình
	else:
		VFX.screen_shake(6.0 + amount * 0.2, 0.15)
```

Không gọi cả `critical_hit` lẫn `screen_shake` cho cùng một cú đánh, vì `critical_hit` đã rung màn hình.

## 5. Dash trail (hạt bám theo)

Hàm `create_dash_trail` không tự dọn nên phải tự quản lý.

```gdscript
var _dash_trail: CPUParticles2D

func start_dash() -> void:
	_dash_trail = VFX.create_dash_trail(self, Vector2(0, 5))  # có thể null

func stop_dash() -> void:
	if _dash_trail == null:
		return
	_dash_trail.emitting = false
	# Chờ hạt cuối cùng tàn rồi mới xóa
	get_tree().create_timer(_dash_trail.lifetime).timeout.connect(_dash_trail.queue_free)
	_dash_trail = null
```

Phương án khác là `trail_2d.tscn` của GDQuest (xem `gdquest-vfx-assets.md`), dải `Line2D` bám theo node.

## 6. Hit stop

```gdscript
VFX.freeze_frame(0.08, 0.1)   # 0.08 giây thực, tốc độ game còn 10%
```

Hàm đổi `Engine.time_scale` toàn game, nên animation, vật lý và âm thanh đều chậm theo. Dùng ngắn (dưới 0.15 giây) và hạn chế gọi liên tiếp.

## 7. Vụ nổ (GDQuest)

```gdscript
var boom := preload("res://effects/2d_explosion/source/explosion.tscn").instantiate()
boom.global_position = target.global_position
get_tree().current_scene.add_child(boom)   # tự queue_free khi animation xong
```

## 8. Môi trường

```gdscript
func _ready() -> void:
	EnvVFX.create_fireflies(self, Vector2(400, 200))
	EnvVFX.create_torch($TorchHolder)
	if is_raining:
		EnvVFX.create_rain(self, 800.0)   # trả về CPUParticles2D, nhớ giữ tham chiếu nếu cần tắt
```

## Khi hiệu ứng "không hiện"

1. Xem tab Output/Debugger có lỗi biên dịch shader không.
2. Uniform sampler còn mặc định (dissolve, frozen, burning, petrify, heat_distortion, fog, clouds2D) chưa gán texture.
3. Shader đọc `TEXTURE` nhưng gắn lên node không có texture (ColorRect trơn).
4. `Camera2D` chưa active (rung màn hình) hoặc autoload `VFX`/`EnvVFX` chưa được bật.
5. Z-index/thứ tự vẽ: hạt nằm sau nền. `create_torch` đặt `z_index = -1` có chủ đích.
6. Sprite dùng chung một `ShaderMaterial` nên mọi bản sao đổi cùng lúc.
