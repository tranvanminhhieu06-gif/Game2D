# License, nguồn và ghi công

Mình không phải luật sư. Đây là tóm tắt từ file LICENSE đọc được; hãy tự xem bản gốc trong `licenses/` và trên repo trước khi phát hành thương mại.

| Repo | Commit đã đọc | License | Lấy gì vào skill | Không lấy |
|---|---|---|---|---|
| [haowg/GODOT-VFX-LIBRARY](https://github.com/haowg/GODOT-VFX-LIBRARY) | `6e8fc84` (2026-01-25) | MIT | Toàn bộ `addons/vfx_library` (code, scene, shader, 4 ảnh hạt, demo) | Ảnh quảng bá `LandOfOblivion.png`, preview, tài liệu cài đặt gốc |
| [gdquest-demos/godot-shaders](https://github.com/gdquest-demos/godot-shaders) | `05a3931` (2026-05-16) | Code/shader/scene: MIT. Ảnh và model 3D: CC-BY-NC-SA 4.0 | 16 shader 2D `canvas_item` | Mọi ảnh, demo, shader 3D |
| [gdquest-demos/godot-4-VFX-assets](https://github.com/gdquest-demos/godot-4-VFX-assets) | `f6034a8` (2026-05-16) | Code/shader/scene/resource: MIT. Ảnh và model 3D: CC-BY-NC-SA 4.0 | Phần `source/` của 5 hiệu ứng 2D và bầu trời 2D | Mọi PNG, model `.obj`, font, `preview/`, `viewer/`, `space`, hiệu ứng 3D |
| [paddy-exe/GodotVisualShader-Extras](https://github.com/paddy-exe/GodotVisualShader-Extras) | `0e86e42` (2023-12-22) | MIT | Không bundle code, chỉ tài liệu | Toàn bộ addon (cài từ repo gốc) |
| [Calinou/awesome-godot](https://github.com/Calinou/awesome-godot) | `9aa855f` (2026-10-05) | CC BY 4.0 | Chỉ tên và liên kết chọn lọc, viết lại mô tả | Không có code |

## Nghĩa vụ khi dùng lại

- **MIT** (VFX-LIBRARY, GDQuest code, VisualShader-Extras): khi phân phối bản sao hay phần đáng kể, giữ nguyên thông báo bản quyền và nội dung license. Bản sao nằm trong `licenses/`. Khi chép shader vào dự án, giữ kèm file license tương ứng (hoặc ghi vào file credits của game).
- **CC-BY-NC-SA 4.0** (ảnh của GDQuest): cấm dùng thương mại và bắt buộc chia sẻ tương tự. Skill này không chứa các ảnh đó. Nếu thêm vào dự án, đồng nghĩa với việc chấp nhận các giới hạn này.
- **CC BY 4.0** (awesome-godot): cần ghi công nếu chép lại nội dung. Skill chỉ viết lại ngắn và dẫn link.

## Điểm chưa xác minh

- 4 ảnh hạt trong `assets/vfx_library/assets/effect/` (fire_particle, firefly, leaf, spark_particle2) nằm trong repo MIT, nhưng mình không biết chúng do tác giả tự làm hay lấy từ nơi khác. Nếu phát hành thương mại, hãy hỏi tác giả hoặc thay bằng ảnh của bạn.
- Chưa kiểm tra license của các công cụ liệt kê trong `awesome-godot-vfx.md`.
- Các shader trong `gdquest-shaders` có thể có chú thích ghi công riêng trong file gốc; mình không đọc từng file.

## Ghi công gợi ý (đưa vào credits của game)

```
VFX: Godot VFX Library by haowg (MIT)
Shaders & effects: GDQuest (godot-shaders, godot-4-VFX-assets, MIT for code)
```

## Cập nhật bản bundle

Các repo nguồn có thể đã thay đổi. Để cập nhật: clone lại từng repo, so sánh với commit trong bảng, rồi chép lại phần tương ứng và cập nhật bảng.
