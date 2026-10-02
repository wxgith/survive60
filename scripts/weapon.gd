class_name Weapon
extends RefCounted
var cooldown := 0.0
func reset() -> void:
	cooldown = 0.0
func advance(delta: float, level: int) -> Array[Vector2]:
	var result: Array[Vector2] = []
	cooldown += delta
	while cooldown + 0.000001 >= 0.22:
		cooldown -= 0.22
		if level == 1:
			result.append(Vector2.UP)
		elif level == 2:
			result.append(Vector2.UP.rotated(-0.09))
			result.append(Vector2.UP.rotated(0.09))
		else:
			result.append(Vector2.UP.rotated(-0.17))
			result.append(Vector2.UP)
			result.append(Vector2.UP.rotated(0.17))
	return result
