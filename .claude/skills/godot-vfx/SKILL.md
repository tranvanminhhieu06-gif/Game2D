---
name: godot-vfx
description: Tạo, chỉnh và tích hợp hiệu ứng hình ảnh 2D cho dự án Godot 4 - particles, shader canvas_item, visual shader, hit flash, dissolve, trail, outline, nước, portal, screen shake, hit stop, status effect (đóng băng, độc, cháy, hóa đá). Dùng khi người dùng nhắc đến VFX, hiệu ứng, shader, particle, game feel, juice, hoặc muốn thêm hiệu ứng vào nhân vật, kẻ địch, môi trường. Godot 4 2D VFX, shaders, particles, hit flash, dissolve, screen shake.
---

# Godot VFX (2D)

Bộ tài liệu và asset đã chắt lọc từ 5 repo mã nguồn mở, chỉ giữ phần 2D và phần code có license MIT. Phiên bản nguồn và license nằm trong `references/licenses.md`.

## Quy trình

1. Đọc `references/project-conventions.md`. Nếu còn ô trống, đọc `project.godot` của dự án để điền (phiên bản Godot, renderer, thư mục đích).
2. Xác định loại hiệu ứng, rồi tra bảng bên dưới và chỉ đọc file cần dùng.
3. Dùng lại asset trong `assets/` trước khi viết mới. Copy vào dự án, không sửa file trong thư mục skill.
4. Viết code theo cú pháp Godot 4 (xem "Quy tắc").
5. Kiểm tra: chạy scene, xem tab Output có lỗi shader không, nhìn hiệu ứng thật trong game. Skill này chưa được chạy thử trong Godot, nên đừng báo "đã kiểm tra" nếu chưa chạy.

## Bản đồ tra cứu

| Cần làm | Đọc file |
|---|---|
| Hit flash, dissolve khi chết, đóng băng, độc, cháy, screen shake, hit stop (công thức có sẵn) | `references/recipes.md` |
| Gọi hiệu ứng particle dựng sẵn (máu, tia lửa, bụi, lửa, mưa, tuyết, sét, portal) | `references/vfx-library.md` |
| Tìm shader theo mục đích (status, outline, nước, hậu kỳ, glow) | `references/shader-catalog-2d.md` |
| Vụ nổ, vortex, trail, nước, bầu trời 2D của GDQuest | `references/gdquest-vfx-assets.md` |
| Node visual shader thêm (blend mode, SDF shapes, UV twirl, wave) | `references/visual-shader-extras.md` |
| Plugin/công cụ ngoài (game feel, camera, trail, chuyển cảnh) | `references/awesome-godot-vfx.md` |
| License, attribution, commit nguồn | `references/licenses.md` |

## Asset đi kèm (`assets/`)

- `vfx_library/` - addon hoàn chỉnh: 30 scene particle, 24 shader, 1 scene demo, hai autoload `VFX` và `EnvVFX`. Chép nguyên thư mục vào `res://addons/vfx_library/` (đường dẫn này cố định vì code dùng `preload`).
- `gdquest-shaders/` - 16 shader 2D (outline, dissolve có mask, palette swap, shockwave, blur, nước, mây).
- `gdquest-vfx-assets/` - scene và shader 2D tự chứa: vụ nổ, vortex, trail, nước, mắt, bầu trời.

## Quy tắc

- Chỉ 2D. Bỏ qua shader `spatial` và `particles` của 3D.
- Godot 4: `material.set_shader_parameter("tên", giá_trị)`. Tween uniform bằng đường dẫn `"shader_parameter/tên"`. Không dùng `set_shader_param` (Godot 3).
- Particle: `CPUParticles2D` chạy được ở mọi renderer (kể cả Compatibility, web, mobile); `GPUParticles2D` hợp khi số lượng hạt lớn. Thư viện `vfx_library` chủ yếu trả về `CPUParticles2D`.
- Hiệu ứng một lần phải tự giải phóng (`queue_free`) sau khi xong, hiệu ứng bám theo phải tắt `emitting` trước khi xóa.
- Không đưa ảnh/texture của repo GDQuest vào dự án thương mại: phần ảnh của họ là CC-BY-NC-SA, skill này cố ý không chứa chúng.
- Khi dùng lại code của repo nào, giữ file LICENSE tương ứng (có sẵn trong `licenses/`).

## Cảnh báo đã biết (từ việc đọc code, chưa chạy thử)

1. `VFX.flash_white()` đặt `modulate = Color.WHITE` rồi tween về giá trị cũ. Vì `modulate` trắng là mặc định nên thường không thấy nháy. Muốn nháy trắng thật, dùng shader `flash_white.gdshader` (xem `recipes.md`).
2. Shader `dissolve.gdshader` có `dissolve_texture` mặc định trắng, nên không thấy hiệu ứng cho tới khi gán một `NoiseTexture2D`.
3. Các shader "hậu kỳ" của `vfx_library` (vignette, radial_blur, chromatic_aberration, grayscale) đọc `TEXTURE`, không đọc màn hình. Gắn vào `ColorRect` trơn sẽ không ra gì; phải gắn vào node có texture (ví dụ `TextureRect` hiển thị `SubViewport`) hoặc sửa sang `hint_screen_texture`.
4. `VFX.screen_shake()` cần một `Camera2D` đang active, nếu không chỉ in cảnh báo.
5. `godot-shaders` của GDQuest đang trong quá trình port sang Godot 4 (README của họ nói vậy, project khai báo 4.3). `godot-4-VFX-assets` khai báo 4.1. `vfx_library` khai báo 4.5+. Nếu dự án dùng bản thấp hơn 4.5, hãy thử trước khi tin.
