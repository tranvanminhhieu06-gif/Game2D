# Danh mục shader 2D

Tất cả là `shader_type canvas_item`. Nguồn viết tắt: **VL** = `assets/vfx_library/shaders/`, **GQ** = `assets/gdquest-shaders/`, **VA** = `assets/gdquest-vfx-assets/`.

Chưa shader nào được biên dịch thử trong Godot (môi trường tạo skill không có Godot). Bảng dưới được lập từ khai báo `uniform` và code đọc được. Cột "Cần texture" nghĩa là uniform sampler đang để mặc định trắng/đen nên phải gán texture mới thấy đúng hiệu ứng.

## Cách áp dụng

- **Lên sprite/nhân vật:** tạo `ShaderMaterial`, gán shader, gán vào `material` của `Sprite2D`/`AnimatedSprite2D`. Hầu hết shader bên dưới đọc `TEXTURE`, tức là chỉ hoạt động trên node có texture.
- **Toàn màn hình:** shader đọc `TEXTURE` cần một node hiển thị hình của game, ví dụ `TextureRect` dùng `SubViewport` làm texture. Chỉ `water.gdshader` (VL) dùng `hint_screen_texture`.
- **Điều khiển bằng code:** `mat.set_shader_parameter("tên", v)`; tween: `create_tween().tween_property(mat, "shader_parameter/tên", v, thời_gian)`.

## Phản hồi trạng thái nhân vật / kẻ địch

| Shader | Nguồn | Uniform chính | Ghi chú |
|---|---|---|---|
| flash_white | VL | `flash_amount`, `flash_color` | Nháy trắng khi bị đánh. Không cần texture. Dùng thay cho `VFX.flash_white` |
| blink | VL | `blink_speed`, `min_alpha` | Nhấp nháy alpha (bất tử tạm thời) |
| dissolve | VL | `dissolve_amount`, `edge_color`, `edge_width` | Cần texture: `dissolve_texture` (gán `NoiseTexture2D`) |
| dissolve2D | GQ | `dissolve_amount`, `burn_color`, `burn_size`, `emission_amount` | Cần texture: `dissolve_texture`. Viền cháy |
| dissolve2D_mask | GQ | `dissolve_amount`, `burn_size` | Biến thể mask, cần `dissolve_texture` |
| burning | VL | `burn_amount`, `fire_color1/2`, `distortion_strength` | Cần texture: `distortion_texture` |
| frozen | VL | `freeze_amount`, `ice_color`, `crystal_intensity` | Cần texture: `ice_texture` |
| poison | VL | `poison_amount`, `poison_color`, `pulse_speed` | Không cần texture |
| petrify | VL | `petrify_amount`, `stone_color`, `crack_intensity` | Cần texture: `crack_texture` |
| invisibility | VL | `invisibility_amount`, `distortion_amount` | Cần texture: `distortion_texture` |
| color_change | VL | `target_color`, `mix_amount`, `preserve_luminance` | Đổi màu, giữ độ sáng tùy chọn |
| grayscale | VL | `grayscale_amount`, `luminance_weights` | Trắng đen, tween để chết/vô hiệu |
| enemy | VL | `blur_amount`, `shake_intensity`, `white_intensity`, `time` | Gộp rung + mờ + nháy trắng. Lấy 81 mẫu mỗi pixel kể cả khi `blur_amount = 0`, nên nặng nếu nhiều kẻ địch. `time` là uniform thường, bạn phải tự cập nhật từ code (không phải `TIME`) |
| shake_intensity | VL | `shake_intensity`, `time` | Rung sprite |
| blur_amount | VL | `blur_amount` | Làm mờ sprite |
| PalettSwap2D | GQ | `palette`, `palette_count`, `palette_index` | Đổi bảng màu (đồng đội/kẻ địch cùng sprite). Cần texture `palette` |

## Viền và phát sáng

| Shader | Nguồn | Uniform chính | Ghi chú |
|---|---|---|---|
| outline_glow | VL | `outline_color`, `outline_width`, `glow_intensity` | Viền phát sáng |
| outline2D_outer | GQ | `line_color`, `line_thickness` | Viền ngoài. Shader chỉ vẽ trong khung texture của sprite, nên viền sát mép ảnh sẽ bị cắt: chừa vài pixel trống quanh sprite |
| outline2D_inner | GQ | `line_color`, `line_thickness` | Viền trong |
| outline2D_inner_outer | GQ | `line_color`, `line_thickness` | Cả hai viền (cùng giới hạn khung texture như viền ngoài) |
| baked_sprite_glow | GQ | `tint_front/back`, `alpha_falloff_front/back`, `blend_amount` | Glow giả lập trên sprite |
| glow_prepass + gaussian_blur_optimized + compose | GQ | `glow_color`, `blur_scale`, `glow_intensity` | Glow nhiều bước dùng SubViewport. Cần dựng pipeline theo demo `Demos/Glow2D/BlurGlow` của repo gốc (không bundle) |
| energy_barrier | VL | `hex_scale`, `barrier_color`, `pulse_speed` | Khiên năng lượng dạng tổ ong |

## Môi trường

| Shader / scene | Nguồn | Uniform chính | Ghi chú |
|---|---|---|---|
| water_surface | VL | `wave_speed`, `wave_frequency`, `wave_amplitude`, `water_tint` | Mặt nước đơn giản, không cần texture |
| water | VL | `level`, `water_albedo`, `water_opacity`, `wave_distortion` | Dùng screen texture (phản chiếu). Cần hai noise texture |
| water_2D | GQ | `shadow_color`, `tile_factor`, `sine_wave_size`... | Nước nhìn từ trên xuống, nhiều uniform; cần texture `texture_offset_uv` |
| 2d_water | VA | `water_color`, `depth_color`, `wave_width`, `wave_height`, `depth` | Nước cạnh bên (side-scroller) có script `2d_water.gd`; dùng screen texture; cần noise |
| heat_distortion | VL | `distortion_speed`, `distortion_amount` | Cần texture `noise_texture` |
| fog | VL | `density`, `speed` | Cần texture `noise_texture` |
| clouds2D | GQ | `scroll_direction_1/2`, `time_scale_1/2`, `tint` | Bóng mây trôi, cần noise và gradient |
| starSky | VL | `small_stars`, `large_stars`, `*_color` | Cần hai texture sao (không có trong bundle) |
| 2d_sky | VA | `top_color`, `scatter_color`, `bottom_color`, `star_*` | Bầu trời ngày/đêm, có `2d_day_sky.tres`, `2d_night_sky.tres` |
| portal_vortex | VL | `vortex_speed`, `vortex_strength`, `portal_color1/2` | Cổng xoáy |
| 2d_vortex | VA | `speed`, `opening`, `bend` | Xoáy; scene `vortex.tscn` |

## Hậu kỳ và hiệu ứng toàn hình

| Shader | Nguồn | Uniform chính | Ghi chú |
|---|---|---|---|
| vignette | VL | `vignette_strength`, `vignette_size`, `vignette_color` | Nhân màu viền (mặc định đỏ) vào ảnh, hợp cho báo máu thấp. Đọc `TEXTURE` |
| radial_blur | VL | `blur_strength`, `blur_center`, `samples` | Mờ xuyên tâm khi dash/hit |
| chromatic_aberration | VL | `aberration_amount`, `aberration_direction` | Lệch kênh màu |
| shockwave | GQ | `mask_texture`, `displacement_amount` | Sóng xung kích: dịch UV theo mask hình vòng; cần texture mask |
| invert | GQ | (không có) | Đảo màu |
| pointilism | GQ | (không có) | Hiệu ứng chấm |
| xray_2d_mask | GQ | `alternate_viewport`, `mask_viewport`, `dimness` | Nhìn xuyên qua mask; cần hai SubViewport |

## Vụ nổ, trail, mắt (scene tự chứa, `VA`)

Xem `gdquest-vfx-assets.md`.

## Chọn nhanh

- Bị đánh: `flash_white`, rồi `enemy` hoặc `shake_intensity` nếu muốn rung.
- Chết: `dissolve2D` hoặc `dissolve` + `NoiseTexture2D`.
- Debuff: `frozen`, `poison`, `burning`, `petrify`.
- Chọn mục tiêu/vật tương tác: `outline2D_outer` hoặc `outline_glow`.
- Máu thấp: `vignette` (nhớ điều kiện `TEXTURE`).
