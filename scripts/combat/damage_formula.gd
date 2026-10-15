class_name DamageFormula
extends RefCounted
## Công thức sát thương theo GDD mục 3.1–3.2.
## Bản rút gọn: mới có giáp tiệm cận và biến thiên ±5%,
## chưa có Ngũ Hành, chí mạng, xuyên giáp và cộng dồn trang bị.

## Hằng số giáp K của bản MVP (100 DEF = giảm 50% sát thương).
const ARMOR_K := 100.0


static func mitigate(raw_damage: float, defense: float, k: float = ARMOR_K) -> float:
	return raw_damage * k / (k + maxf(defense, 0.0)) * randf_range(0.95, 1.05)
