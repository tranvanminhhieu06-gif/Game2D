# GODOT-VFX-LIBRARY (haowg)

Nguồn: https://github.com/haowg/GODOT-VFX-LIBRARY - MIT - khai báo Godot 4.5+, Forward Plus - thiết kế cho game 2D hành động (Metroidvania, platformer).
Bản bundle: `assets/vfx_library/` (commit ghi trong `licenses.md`).

## Cài đặt

1. Chép `assets/vfx_library/` vào `res://addons/vfx_library/`. Tên thư mục phải đúng như vậy vì code dùng `preload("res://addons/vfx_library/...")`.
2. Project Settings > Plugins > bật "VFX Library". Plugin tự thêm hai autoload `VFX` (vfx.gd) và `EnvVFX` (env_vfx.gd).
3. Nếu không muốn bật plugin, tự thêm hai autoload đó trong Project Settings > Globals.
4. Mở `addons/vfx_library/demo/vfx_demo.tscn` và chạy (F6) để xem từng hiệu ứng.

## VFX (combat, di chuyển, màn hình)

| Hàm | Ghi chú |
|---|---|
| `screen_shake(intensity=10.0, duration=0.2)` | Rung `Camera2D.offset`, cần camera active |
| `freeze_frame(duration=0.1, time_scale=0.05)` | Đổi `Engine.time_scale`, gộp nhiều yêu cầu bằng cách lấy giá trị nhỏ nhất, timer bỏ qua time_scale |
| `critical_hit(pos)` | Shake 15/0.25s + freeze 0.12s + hạt cam |
| `kill_effect(pos)` | Shake 12/0.2s + freeze 0.08s + hạt đỏ |
| `spawn_blood_splash(pos)` | ~1.0s, tự dọn |
| `spawn_energy_burst(pos, color)` | ~1.0s, tự dọn |
| `spawn_heal_effect(pos)` | ~2.0s, hạt bay lên |
| `spawn_shield_break(pos)` | ~0.8s |
| `spawn_combo_ring(pos)` | ~0.6s |
| `spawn_particles(pos, color, count=15)` | Hạt chung, ~1.2s |
| `spawn_damage_number(pos, damage, is_critical=false)` | Số sát thương nổi |
| `spawn_jump_dust(pos)` | ~0.5s |
| `create_dash_trail(parent, offset)` -> CPUParticles2D | Thêm làm con của parent, `emitting = true`. **Không tự tắt, không tự dọn**: bạn phải tắt `emitting` và `queue_free()`. Trả về `null` nếu parent không hợp lệ |
| `create_wall_slide_spark(parent, offset)` -> CPUParticles2D | Giống dash trail: phát liên tục, tự quản lý vòng đời, có thể trả về `null` |
| `flash_white(node, duration=0.1)` | Xem cảnh báo bên dưới |

## EnvVFX (môi trường, phép thuật)

Ánh sáng/lửa: `create_torch`, `create_candle_flame`, `create_campfire_smoke` (parent, offset).
Không khí: `create_fireflies(parent, area_size)`, `create_falling_leaves(parent, width)`, `create_ash_particles(parent, area_size)`.
Thời tiết: `create_rain(parent, area_width)`, `create_snow(parent, area_width)`.
Nước/hơi: `create_water_splash(pos, size, parent)`, `create_waterfall_mist(parent, offset, width)`, `create_steam(parent, offset)`.
Cơ khí: `create_sparks(parent, offset, continuous)`, `create_dust_cloud(pos, size, parent)`, `create_wood_debris(pos, direction, parent)`.
Phép thuật: `create_magic_aura(parent, color, radius)` (GPUParticles2D), `create_portal(parent, offset)`, `spawn_lightning_chain(pos)`, `spawn_ice_frost(pos)`, `create_fireball_trail(parent, offset)`, `create_summon_circle(parent, offset, radius)`.
Độc: `create_poison_cloud(pos, size, parent)` (persistent, phải tự dọn).

Quy ước chung (theo API_REFERENCE và code): hàm `spawn_*` và `create_*(pos, ...)` không trả về gì và tự dọn (trừ `create_poison_cloud` trả về node persistent); hàm `create_*(parent, ...)` trả về node particle liên tục, bạn phải tự `emitting = false` rồi `queue_free()`. `create_torch` trong code chỉ thêm node vào parent và đặt `z_index = -1`, không có dọn dẹp tự động.

## Scene particle (`effects/`)

ash_particles, blood_splash, campfire_smoke, candle_flame, combat_particle, combo_ring, dash_trail, dust_cloud, energy_burst, falling_leaves, fireball_trail, fireflies, heal_particles, ice_frost, jump_dust, lightning_chain, magic_aura, poison_cloud, portal_vortex, rain_drops, shield_break, snow_flakes, sparks, steam, summon_circle, torch_fire, wall_slide_spark, water_splash, waterfall_mist, wood_debris.

Muốn chỉnh màu, số hạt, thời gian: mở thẳng file `.tscn` trong editor, hoặc đổi thuộc tính trên node trả về.

## Shader (`shaders/`)

Danh sách và uniform nằm trong `shader-catalog-2d.md`.

## Cảnh báo

- `flash_white` trong `vfx.gd` đặt `modulate = Color.WHITE` rồi tween về giá trị ban đầu. `modulate` trắng không đổi màu sprite, nên theo logic code thì hiệu ứng chỉ thấy khi node đang có modulate khác trắng. Dùng shader `flash_white.gdshader` (công thức trong `recipes.md`) nếu muốn nháy trắng thật.
- `screen_shake` lưu `camera.offset` lúc gọi làm vị trí gốc. Gọi chồng nhiều lần liên tiếp có thể làm camera dừng lệch; nên giới hạn tần suất.
- `freeze_frame` đổi `Engine.time_scale` toàn game, gồm cả animation và âm thanh dùng time scale.
- Thư viện tự ghi chú ngưỡng khuyến nghị: số hạt 5-50 cho `spawn_particles`, `size` 0.5-3.0 cho splash/dust/poison.

## Hiệu năng

Giới hạn số hiệu ứng cùng lúc (ví dụ tối đa 5 máu), giảm `amount` trên mobile (ví dụ chia đôi), và ưu tiên hiệu ứng tự dọn cho va chạm đơn giản. Đây là khuyến nghị trong API_REFERENCE của repo, chưa được đo trong dự án của bạn.
