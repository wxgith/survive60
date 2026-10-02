class_name Player
extends Node2D
const SPEED := 360.0
const RADIUS := 13.0
var invulnerable := false
var animation_time := 0.0
func reset() -> void:
	position = Vector2(480, 530)
	invulnerable = false
	queue_redraw()
func move(input: Vector2, delta: float) -> void:
	position += input.limit_length() * SPEED * delta
	position = position.clamp(Vector2(24, 88), Vector2(936, 606))
	animation_time += delta
	queue_redraw()
func _draw() -> void:
	if invulnerable and int(animation_time * 14.0) % 2 == 0:
		return
	var glow := Color("38f4e8")
	draw_circle(Vector2.ZERO, 29, Color(0.1, 0.95, 0.85, 0.07))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -23), Vector2(19, 18), Vector2(0, 10), Vector2(-19, 18)]), Color("123f50"))
	draw_polyline(PackedVector2Array([Vector2(0, -23), Vector2(19, 18), Vector2(0, 10), Vector2(-19, 18), Vector2(0, -23)]), glow, 2.0, true)
	draw_line(Vector2(0, -9), Vector2(0, 8), Color.WHITE, 3.0, true)
	var flame := 14.0 + sin(animation_time * 30.0) * 5.0
	draw_colored_polygon(PackedVector2Array([Vector2(-5, 16), Vector2(0, 16 + flame), Vector2(5, 16)]), Color("efbe6a"))
