# GDQuest godot-4-VFX-assets (phần 2D)

Nguồn: https://github.com/gdquest-demos/godot-4-VFX-assets - khai báo Godot 4.1 (Forward Plus).
License: code/scene/shader/resource do Godot sinh ra là **MIT**; ảnh texture và model 3D là **CC-BY-NC-SA 4.0**. Bản bundle `assets/gdquest-vfx-assets/` chỉ chứa phần MIT (không có PNG, không có model 3D, không có thư mục `preview/` và `viewer/`).

Các scene bên dưới chỉ phụ thuộc shader và script; gradient/curve nằm trong chính file `.tres`/`.tscn`, nên tự chứa được.

## Cách đưa vào dự án

Các file tham chiếu nhau bằng đường dẫn tuyệt đối dạng `res://effects/2d_explosion/source/...`.

- Cách 1: chép `effects/` và `backgrounds/` vào gốc `res://` của dự án, giữ nguyên đường dẫn.
- Cách 2: chép vào chỗ bạn muốn, rồi mở dự án và dùng **di chuyển/đổi tên trong dock FileSystem** của Godot để editor cập nhật tham chiếu. Nếu chép tay vào thư mục khác, tham chiếu sẽ hỏng.

## Danh sách

| Hiệu ứng | Scene | Cách hoạt động | Cách dùng |
|---|---|---|---|
| Vụ nổ | `effects/2d_explosion/source/explosion.tscn` | `Node2D` gồm 3 `ColorRect` (`Trace`, `RedCircle`, `FireCircle`) chạy shader + `GPUParticles2D` + `AnimationPlayer` | `instantiate()` rồi `add_child`, đặt `global_position`. Script `explosion.gd` tự random offset, phát animation `default` và `queue_free()` khi xong |
| Trail theo vật | `effects/2d_trail/source/trail_2d.tscn` | `Line2D` có `top_level = true`, script `trail_2d.gd` | Thêm làm con của node cần bám, gán `follow_node` (nếu để trống dùng `owner`). `points_count` mặc định 16 |
| Vortex | `effects/2d_vortex/source/vortex.tscn` | Shader xoáy: `speed`, `opening`, `bend` | Instance vào cảnh |
| Nước cạnh bên | `effects/2d_water/source/2d_water.gdshader` + `2d_water.gd` | `ColorRect` + `ShaderMaterial`; script `@tool` cập nhật uniform `size` mỗi khi đổi kích thước | Tự tạo `ColorRect`, gán shader và script. Shader lấy screen texture nên cần cảnh phía sau; cần gán noise `noise_sampler` |
| Mắt | `effects/2d_eyeball/source/eyeball.tscn` | `ColorRect` 128x128 chạy shader mắt | Điều khiển `eye_offset`, `pupil_dilation`, màu mống mắt qua `ShaderMaterial` |
| Bầu trời ngày/đêm | `backgrounds/2d_sky/source/2d_sky.gdshader`, `2d_day_sky.tres`, `2d_night_sky.tres` | `ColorRect` + shader gradient + mặt trời/trăng/sao | Tạo `ColorRect` phủ nền, gán một trong hai material và script `2d_sky.gd` |

## Trail: ví dụ

```gdscript
# Gắn Trail2D làm con của nhân vật rồi gán follow_node
var trail := preload("res://effects/2d_trail/source/trail_2d.tscn").instantiate()
add_child(trail)
trail.follow_node = self
trail.points_count = 20
```

`trail_2d.gd` cập nhật điểm trong `_physics_process`; điểm đầu bám `follow_node.global_position`, các điểm sau nội suy theo điểm trước. Muốn tắt trail khi đứng yên, đổi `visible` hoặc `queue_free()` node.

## Không bundle

- `backgrounds/space/` (có PNG CC-BY-NC-SA), `to_sort/`, `materials/`, các hiệu ứng `3d_*`, bộ `viewer/`.
- Nếu muốn dùng, lấy từ repo gốc và tôn trọng giới hạn phi thương mại + share-alike của phần ảnh.

## Lưu ý

- Chưa chạy thử trong Godot. Repo khai báo 4.1; nếu dự án dùng bản mới hơn, Godot có thể yêu cầu cập nhật vài resource khi mở lần đầu.
- Các shader `explosion*` đọc gradient trong `.tres`; đừng chép riêng file shader mà bỏ file material, hiệu ứng sẽ mất gradient.
