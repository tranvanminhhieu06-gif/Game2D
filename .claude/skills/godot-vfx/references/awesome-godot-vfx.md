# Công cụ ngoài liên quan VFX 2D (chọn từ awesome-godot)

Nguồn danh sách: https://github.com/Calinou/awesome-godot (CC BY 4.0, đọc commit 9aa855f, 2026-10-05).
`awesome-godot` chỉ là danh sách liên kết. Mình chỉ đọc mô tả một dòng của từng mục, **chưa mở từng repo** để kiểm tra phiên bản Godot, license hay tình trạng bảo trì. Trước khi cài bất kỳ mục nào, mở repo của nó và kiểm tra các điều đó. Cột "Lưu ý" chỉ ghi điều suy ra từ tên hoặc mô tả trong danh sách.

## Game feel, camera

| Công cụ | Link | Mô tả trong danh sách | Lưu ý |
|---|---|---|---|
| Juicee | https://github.com/Kelpekk/Juicee | Screen shake, hit stop, hiệu ứng camera, có graph editor và API một dòng | Cùng nhóm việc với `VFX.screen_shake`/`freeze_frame` |
| Shaker | https://github.com/Eneskp3441/Shaker | Rung và emitter cho camera, node hay thuộc tính bất kỳ, 2D và 3D | |
| Phantom Camera | https://github.com/ramokz/phantom-camera | Đơn giản hóa hành vi `Camera2D`/`Camera3D` | |
| Camera2D Screen Shake | https://godotengine.org/qa/438/camera2d-screen-shake-extension | Mở rộng rung cho Camera2D | Bài hỏi đáp cũ, có thể là code Godot 3 |

## Trail, đường, phá hủy

| Công cụ | Link | Mô tả trong danh sách | Lưu ý |
|---|---|---|---|
| Godot-Trail-System | https://github.com/OBKF/Godot-Trail-System | Trail 2D/3D nâng cao | Phương án thay cho `trail_2d` của GDQuest |
| AntialiasedLine2D | https://github.com/godot-extended-libraries/godot-antialiased-line2d | Line2D/Polygon2D khử răng cưa tốt hơn | |
| Godot Polygon 2D Fracture | https://github.com/SoloByte/godot-polygon2d-fracture | Cắt và vỡ polygon | |
| 2D Destructible Objects | https://github.com/hiulit/Godot-3-2D-Destructible-Objects | Chia sprite thành khối rồi nổ tung | Tên repo có "Godot-3" |

## Animation, chuyển cảnh, ánh sáng

| Công cụ | Link | Mô tả trong danh sách | Lưu ý |
|---|---|---|---|
| Anima | https://github.com/ceceppa/anima | Animation tuần tự/song song gọn hơn Tween | |
| Scene Manager | https://github.com/glass-brick/Scene-Manager | Chuyển cảnh tùy biến một dòng | Danh sách ghi Godot 3 và 4 |
| AnimSheet | https://github.com/Lighar/AnimSheet | Tạo AnimationPlayer/AnimatedSprite2D từ spritesheet | |
| Aseprite Wizard | https://github.com/viniciusgerevini/godot-aseprite-wizard | Nhập animation Aseprite | |
| 2D Day/Night Cycle | https://github.com/hiulit/Godot-3-2D-Day-Night-Cycle | Chu kỳ ngày đêm 2D | Tên repo có "Godot-3" |

## Shader và hiệu năng

| Công cụ | Link | Mô tả trong danh sách | Lưu ý |
|---|---|---|---|
| Godot Shaders (website) | https://godotshaders.com/ | Thư viện shader cộng đồng | Mỗi shader có license riêng, kiểm tra từng cái |
| Godot Shader Warmup | https://github.com/Koisuji02/GodotShaderWarmup | Làm nóng shader lúc khởi động để tránh giật khi biên dịch | Hữu ích khi nhiều hiệu ứng lần đầu xuất hiện giữa trận |
| SimpleGodotCRTShader | https://github.com/henriquelalves/SimpleGodotCRTShader | Giả lập màn hình CRT | |
| CRT Shader | https://github.com/hiulit/Godot-3-2D-CRT-Shader | CRT nhiều tham số | Tên repo có "Godot-3" |

## Cố ý bỏ qua

- `EffekseerForGodot3` (Godot 3) và mọi mục 3D-only (Volumetrics, LOD...).
- Mục chỉ dành cho editor/IDE, theme, template game.

## Cách dùng khi có yêu cầu

Nếu người dùng hỏi một việc mà `assets/` của skill đã làm được (rung màn hình, trail, nháy trắng), dùng asset sẵn có trước. Chỉ đề xuất công cụ ngoài khi cần tính năng skill không có (graph editor game feel, vỡ polygon, chuyển cảnh), và nói rõ rằng chưa kiểm tra tương thích với phiên bản Godot của họ.
