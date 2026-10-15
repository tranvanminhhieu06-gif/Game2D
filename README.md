# Vọng Cổ Thần Tích

Action RPG 2D top-down, bối cảnh cổ trang & thần thoại Việt Nam. Làm bằng Godot 4.7 (GDScript, renderer Mobile).
Thiết kế chi tiết nằm trong `Tổng Quan Dự Án.docx` (GDD).

## Mở project

1. Mở Godot 4.7.x → **Import** → chọn file `project.godot` ở thư mục gốc repo.
2. Nhấn **F5** để chạy scene chính `scenes/levels/greybox_test.tscn`.

Điều khiển hiện có:

| Hành động | Bàn phím | Tay cầm |
|---|---|---|
| Di chuyển | WASD / Mũi tên | Cần trái / D-pad |

## Cấu trúc thư mục

```
project.godot          Cấu hình Godot (input map, tên lớp va chạm, độ phân giải)
scenes/
  levels/              Màn chơi (greybox_test.tscn = bản xám thử di chuyển)
  player/              Scene nhân vật người chơi
scripts/
  player/              Logic người chơi
  props/               Vật thể trong màn (GreyboxBlock: khối chắn tạm)
  levels/              Script phụ trợ cho màn chơi
```

Các thư mục tài liệu/concept art (`Playable Classes/`, `Enemy Roster/`…) có file `.gdignore` nên Godot bỏ qua, không import ảnh 8 MB vào game.

## Quy ước

- **Gốc tọa độ ở chân** nhân vật/vật thể và bật `y_sort_enabled` ở node cha để vật ở thấp hơn trên màn hình được vẽ đè lên.
- **Lớp va chạm 2D** (đã đặt tên trong Project Settings):
  1 `world` · 2 `player` · 3 `enemy` · 4 `player_hitbox` · 5 `enemy_hitbox` · 6 `interactable`.
- **Độ phân giải gốc** 1280×720, stretch `canvas_items`, aspect `expand`.
- Asset đưa vào game đặt tên ASCII `snake_case` (không dấu, không khoảng trắng).
- Godot 4.4+ sinh file `*.uid` cạnh script/shader: **commit cả các file này**. Thư mục `.godot/` đã nằm trong `.gitignore`.

## Trạng thái

- [x] Khung project, input map, lớp va chạm
- [x] Bản xám: nhân vật đi 8 hướng có gia tốc/hãm, camera bám theo, khối chắn để thử va chạm và Y-sort
- [ ] Lướt né (Dash) + Thể Lực, đánh thường 3 nhịp
- [ ] Quái thường với FSM 4 trạng thái
- [ ] Hệ thống chỉ số & công thức sát thương theo GDD
