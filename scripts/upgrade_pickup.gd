class_name UpgradePickup
extends Node2D
signal collected
var age := 0.0
var expired := false
func setup(origin: Vector2) -> void:
	position = origin
	age = 0.0
	expired = false
func advance(delta: float) -> void:
	age += delta
	position.y += 25.0 * delta
	expired = age + 0.000001 >= 8.0 or position.y > 670
	queue_redraw()
func collect() -> bool:
	if expired:
		return false
	expired = true
	collected.emit()
	return true
func _draw() -> void:
	if age > 6.0 and int(age * 8.0) % 2 == 0:
		return
	var size := 12.0 + sin(age * 5.0) * 2.0
	draw_circle(Vector2.ZERO, 23, Color(0.2, 1, 0.68, 0.1))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -size), Vector2(size, 0), Vector2(0, size), Vector2(-size, 0)]), Color("193f37"))
	draw_polyline(PackedVector2Array([Vector2(0, -size), Vector2(size, 0), Vector2(0, size), Vector2(-size, 0), Vector2(0, -size)]), Color("7ef8b7"), 2, true)
	draw_line(Vector2(0, -5), Vector2(0, 5), Color.WHITE, 2)
	draw_line(Vector2(-5, 0), Vector2(5, 0), Color.WHITE, 2)
