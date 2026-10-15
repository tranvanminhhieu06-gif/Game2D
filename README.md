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
| Lướt né (Dash) | Space | Nút B |
| Đánh thường (Tam Liên Kích) | J / Chuột trái | Nút X |

## Cấu trúc thư mục

```
project.godot          Cấu hình Godot (input map, tên lớp va chạm, độ phân giải)
data/
  skills/              Dữ liệu kỹ năng (.tres), ví dụ 3 đòn Tam Liên Kích
scenes/
  levels/              Màn chơi (greybox_test.tscn = bản xám thử di chuyển & đánh)
  player/              Scene nhân vật người chơi
  props/               Vật thể (hình nộm tập võ)
scripts/
  combat/              AttackStep, Hurtbox, công thức sát thương
  player/              Logic người chơi
  props/               Vật thể trong màn (GreyboxBlock, TrainingDummy)
  levels/              Script phụ trợ cho màn chơi
  ui/                  HUD (thanh Thể Lực tạm, số sát thương bay lên)
```

Các thư mục tài liệu/concept art (`Playable Classes/`, `Enemy Roster/`…) có file `.gdignore` nên Godot bỏ qua, không import ảnh 8 MB vào game.

## Quy ước

- **Gốc tọa độ ở chân** nhân vật/vật thể và bật `y_sort_enabled` ở node cha để vật ở thấp hơn trên màn hình được vẽ đè lên.
- **Lớp va chạm 2D** (đã đặt tên trong Project Settings):
  1 `world` · 2 `player` · 3 `enemy` · 4 `player_hitbox` · 5 `enemy_hitbox` · 6 `interactable`.
  Hurtbox của kẻ địch nằm ở lớp 3; vùng đánh của người chơi ở lớp 4 và quét lớp 3.
- **Độ phân giải gốc** 1280×720, stretch `canvas_items`, aspect `expand`.
- Asset đưa vào game đặt tên ASCII `snake_case` (không dấu, không khoảng trắng).
- Godot 4.4+ sinh file `*.uid` cạnh script/shader: **commit cả các file này**. Thư mục `.godot/` đã nằm trong `.gitignore`.

## Trạng thái

- [x] Khung project, input map, lớp va chạm
- [x] Bản xám: nhân vật đi 8 hướng có gia tốc/hãm, camera bám theo, khối chắn để thử va chạm và Y-sort
- [x] Lướt né (Dash): tốn 25 Thể Lực, bất tử 0.25 giây; Thể Lực 100, hồi 15/giây (theo GDD), có thanh Thể Lực tạm
- [x] Đánh thường 3 nhịp (Tam Liên Kích): đòn 1–2 = 100% ATK, đòn 3 = 120% ATK kèm hất lùi; hình nộm tập võ hiện số sát thương theo công thức giáp K = 100
- [ ] Quái thường với FSM 4 trạng thái
- [ ] Hệ thống chỉ số & công thức sát thương theo GDD
