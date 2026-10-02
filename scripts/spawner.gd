class_name Spawner
extends RefCounted
var rng := RandomNumberGenerator.new()
var clock := 0.0
func reset(seed_value: int) -> void:
	clock = 0.0
	if seed_value < 0:
		rng.randomize()
	else:
		rng.seed = seed_value
func advance(delta: float, elapsed: float, interval: float) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if elapsed <= 2.0:
		return result
	clock += minf(delta, elapsed - 2.0)
	while clock + 0.000001 >= interval:
		clock -= interval
		var stage := 0 if elapsed < 20.0 else (1 if elapsed < 40.0 else 2)
		var speed: float = [100.0, 145.0, 190.0][stage]
		result.append({"position": Vector2(rng.randf_range(40, 920), 38), "velocity": Vector2(rng.randf_range(-130, 130), speed * rng.randf_range(0.85, 1.2)), "hp": 2 if rng.randf() < 0.32 else 1})
	return result
