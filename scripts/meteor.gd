class_name Meteor
extends Node2D
signal destroyed(world_position: Vector2)
var velocity := Vector2.ZERO
var previous_position := Vector2.ZERO
var health := 1
var radius := 19.0
var dead := false
var spin := 0.0
var angle := 0.0
func setup(origin: Vector2, drift: Vector2, hit_points: int) -> void:
	position = origin
	previous_position = origin
	velocity = drift
	health = hit_points
	radius = 29.0 if health == 2 else 19.0
	spin = 0.7 if int(origin.x) % 2 == 0 else -0.6
	dead = false
func advance(delta: float) -> void:
	previous_position = position
	position += velocity * delta
	angle += spin * delta
	if position.y > 690 or position.x < -60 or position.x > 1020:
		dead = true
	queue_redraw()
func take_hit() -> bool:
	if dead:
		return false
	health -= 1
	if health <= 0:
		dead = true
		destroyed.emit(position)
		return true
	queue_redraw()
	return false
func _draw() -> void:
	var points := PackedVector2Array()
	for i in range(9):
		var a := angle + i * TAU / 9.0
		points.append(Vector2.from_angle(a) * radius * (0.8 + 0.2 * absf(sin(i * 4.7))))
	draw_colored_polygon(points, Color("3b2434") if health == 1 else Color("342c49"))
	points.append(points[0])
	draw_polyline(points, Color("f6a178") if health == 1 else Color("c6a3ff"), 2.0, true)
	draw_arc(Vector2(-radius * 0.18, radius * 0.12), radius * 0.32, 0, TAU, 16, Color(0.9, 0.6, 0.5, 0.22), 2, true)
