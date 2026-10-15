# Quy ước của dự án

Điền các ô trống trước khi dùng skill. Nếu dự án có sẵn `project.godot`, đọc nó để điền thay vì hỏi người dùng (mục `config/features` cho biết phiên bản Godot và renderer).

| Mục | Giá trị | Ghi chú |
|---|---|---|
| Tên dự án | Game2D | Thư mục trên máy: `C:\Users\PC\OneDrive\Máy tính\Game2D`. `project.godot` nằm ở thư mục gốc repo (tạo 2026-10-15) |
| Phiên bản Godot | 4.7.2 stable (Windows 64-bit) | Theo file exe của người dùng. `vfx_library` khai báo 4.5+; `godot-shaders` 4.3; `godot-4-VFX-assets` 4.1; `VisualShader-Extras` 4.2+. Chưa kiểm tra riêng trên 4.7.2 |
| Renderer | Mobile (`config/features` = `4.7`, `Mobile` trong `project.godot`) | Khi project được tạo, đọc `config/features` để xác nhận. "Mobile" vừa là tên renderer vừa là nền tảng đích: nếu thật sự nhắm điện thoại phổ thông/yếu thì cân nhắc Compatibility. Với thiết bị yếu: ưu tiên `CPUParticles2D`, giảm số hạt, tránh shader lấy nhiều mẫu mỗi pixel (như `enemy.gdshader`) và shader dùng screen texture nếu chưa thử trên máy thật |
| Ngôn ngữ script | GDScript | Các công thức trong `recipes.md` dùng trực tiếp được |
| Thể loại | RPG 2D | Ưu tiên: nháy trắng khi trúng đòn, dissolve khi chết, trạng thái (đóng băng/độc/cháy), số sát thương, outline chọn mục tiêu, hiệu ứng phép thuật, môi trường (đuốc, đom đóm, mưa). Cần cẩn thận với `freeze_frame` vì đổi `Engine.time_scale` toàn game, gồm cả menu/hội thoại nếu chúng dùng time scale |
| Độ phân giải / pixel art | 1280×720, stretch `canvas_items`, aspect `expand`; art vẽ tay (không phải pixel art), texture filter mặc định Linear | Pixel art: tránh blur, đặt texture filter `Nearest`; kiểm tra shader làm mờ có hợp không |
| Thư mục shader | `res://vfx/shaders/` | _(đổi nếu dự án có quy ước khác)_ |
| Thư mục scene hiệu ứng | `res://vfx/effects/` | Riêng `effects/` của GDQuest cần giữ nguyên đường dẫn, xem `gdquest-vfx-assets.md` |
| Autoload hiện có | Chưa có | Tránh trùng tên với `VFX`, `EnvVFX` |
| Camera | `Camera2D` con của `Player` (`scenes/player/player.tscn`), bật position smoothing, chưa có rung riêng | `VFX.screen_shake` đổi `offset` của camera active; xung đột nếu dự án đã tự rung camera |
| Giới hạn hiệu năng | _(thiết bị thấp nhất cần chạy)_ | |

## Quy tắc đặt tên đề xuất

- Shader: `snake_case.gdshader`, đặt tên theo hiệu ứng (`flash_white`, `dissolve`).
- Material dùng lại: lưu `.tres` cạnh shader.
- Scene hiệu ứng một lần: tự `queue_free()` khi xong; scene bám theo: có hàm dừng rõ ràng.

## Nhật ký thay đổi

Ghi lại mỗi lần thêm hiệu ứng (ngày, hiệu ứng, file nguồn) để lần sau biết cái nào đến từ đâu và còn nghĩa vụ ghi công nào.

- _(chưa có)_
