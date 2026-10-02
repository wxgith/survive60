class_name Bullet
extends Node2D
var direction := Vector2.UP
var previous_position := Vector2.ZERO
var spent := false
var offscreen := false
func setup(origin: Vector2, heading: Vector2) -> void:
	position = origin
	previous_position = origin
	direction = heading.normalized()
func advance(delta: float) -> void:
	previous_position = position
	position += direction * 640.0 * delta
	if position.y < 48 or position.x < -10 or position.x > 970:
		offscreen = true
func hits_circle(center: Vector2, radius: float) -> bool:
	return Geometry2D.get_closest_point_to_segment(center, previous_position, position).distance_squared_to(center) <= pow(radius + 3.0, 2)
func hits_moving_circle(previous_center: Vector2, current_center: Vector2, radius: float) -> bool:
	var relative_start := previous_position - previous_center
	var relative_end := position - current_center
	return Geometry2D.get_closest_point_to_segment(Vector2.ZERO, relative_start, relative_end).length_squared() <= pow(radius + 3.0, 2)
func _draw() -> void:
	draw_line(Vector2.ZERO, -direction * 17, Color(0.25, 1, 0.85, 0.16), 8, true)
	draw_line(Vector2.ZERO, -direction * 14, Color("c2fff3"), 3, true)
