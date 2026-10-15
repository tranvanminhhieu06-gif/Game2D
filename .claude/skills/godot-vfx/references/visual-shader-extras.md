# GodotVisualShader-Extras (paddy-exe)

Nguồn: https://github.com/paddy-exe/GodotVisualShader-Extras - MIT - nhánh `4.x` chỉ dành cho **Godot 4.2 trở lên** (nhánh `v4.1` dành cho 4.1). Commit đã đọc: 2023-12-22, tức repo không còn cập nhật gần đây; nếu dự án dùng Godot 4.5 hoặc mới hơn, hãy thử trong dự án trước khi dựa vào nó.
Đây là addon **thêm node cho Visual Shader editor**, không phải thư viện hiệu ứng dựng sẵn. Skill này không bundle nó (cài từ repo gốc để có bản cập nhật).

## Cài đặt

1. Tải repo, chép thư mục `addons/VisualShaderExtras` vào `res://addons/` của dự án (tạo `addons/` nếu chưa có).
2. Không cần bật trong Project Settings (README nói rõ không cần kích hoạt; repo không có `plugin.cfg`).
3. Mở một `VisualShader`, thêm node bằng menu Add Node và tìm theo tên node bên dưới.

Scene mẫu trong repo: `addons/VisualShaderExtras/AddonExamples/examples2D.tscn`.

## Node có sẵn

| Nhóm | Node |
|---|---|
| Blend mode | Normal, Dissolve, Screen, Overlay, Hard Light, Soft Light, Burn, Dodge, Lighten, Darken, Difference, Additive, AddSub, Linear Light, Vivid Light, Pin Light, Hard Mix, Exclusion, Gamma Illumination, Gamma Light, Gamma Dark, Luminosity, Linear Burn |
| Procedural | Checkerboard, PSRD Noise 2D, PSRD Noise 3D, Radial Gradient |
| Hình SDF | Box, Circle, Rounded Box, Rotated Box, Trapezoid, Triangle, Rhombus, Parallelogram, Hyperbolic Cross, Precise Hyperbolic Cross |
| UV | UV Twirl, UV Flipbook, UV Tiler, UV Rotate (thêm `UVtoSphereCoord` trong thư mục UV của repo) |
| Sóng | Triangle, Square, Sawtooth, Sine, Sine (angular frequency) |
| Màu | HSV Adjustment |

## Gợi ý dùng trong 2D (ý tưởng của skill, chưa kiểm tra)

- **UV Twirl** + noise: xoáy portal, vortex.
- **UV Flipbook**: chạy sprite sheet hiệu ứng ngay trong shader.
- **Hình SDF (Circle, Box, Rounded Box)**: mask tròn/vuông cho vòng cooldown, thanh máu, vùng sáng.
- **Sine/Triangle Wave**: nhấp nháy, rung, dao động alpha.
- **Blend mode** (Screen, Overlay, Additive): chồng lớp glow/lửa lên sprite.
- **HSV Adjustment**: đổi tông màu kẻ địch cùng sprite.

## Khi nào dùng visual shader thay vì `.gdshader`

Chọn visual shader khi bạn muốn thử nghiệm bằng giao diện nút. Với hiệu ứng sẽ được Claude viết/sửa hàng loạt hoặc cần review diff, file `.gdshader` (văn bản) dễ kiểm soát hơn, vì `.tres` của VisualShader khó đọc trong diff.
