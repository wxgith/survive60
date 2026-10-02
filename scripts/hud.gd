class_name HUD
extends Control
signal start_requested
signal resume_requested
signal restart_requested
const State = preload("res://scripts/run_state.gd")
const FONT = preload("res://assets/survive60-ui.otf")
var state
var main_button := Button.new()
var pause_button := Button.new()
const CYAN := Color("63f1df")
const MUTED := Color("8294ad")
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(960, 640)
	z_index = 100
	main_button.position = Vector2(348, 412)
	main_button.size = Vector2(264, 48)
	main_button.add_theme_font_override("font", FONT)
	main_button.add_theme_font_size_override("font_size", 19)
	main_button.add_theme_color_override("font_color", Color("08282c"))
	for mode in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = CYAN if mode != "hover" else Color("a0ffe9")
		style.set_corner_radius_all(7)
		main_button.add_theme_stylebox_override(mode, style)
	main_button.pressed.connect(_activate)
	add_child(main_button)
	pause_button.position = Vector2(864, 20)
	pause_button.size = Vector2(72, 34)
	pause_button.text = "暂停"
	pause_button.add_theme_font_override("font", FONT)
	pause_button.add_theme_font_size_override("font_size", 15)
	pause_button.pressed.connect(func():
		if state != null: state.set_paused(true))
	add_child(pause_button)
func _activate() -> void:
	if state == null: return
	match state.phase:
		State.Phase.READY: start_requested.emit()
		State.Phase.PAUSED: resume_requested.emit()
		State.Phase.WON, State.Phase.LOST: restart_requested.emit()
func render_state(current: RunState) -> void:
	state = current
	main_button.visible = state.phase != State.Phase.RUNNING
	pause_button.visible = state.phase == State.Phase.RUNNING
	main_button.text = "开始游戏  ↗" if state.phase == State.Phase.READY else ("继续飞行" if state.phase == State.Phase.PAUSED else "再来一局  ↻")
	queue_redraw()
func text_at(text: String, position: Vector2, font_size: int, color: Color, width: float = -1, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
	draw_string(FONT, position, text, align, width, font_size, color)
func _draw() -> void:
	if state == null: return
	draw_rect(Rect2(0, 0, 960, 72), Color("091324"))
	draw_line(Vector2(24, 71), Vector2(936, 71), Color("214050"), 1)
	text_at("SURVIVE / 60", Vector2(24, 32), 19, CYAN)
	text_at("撑过60秒", Vector2(24, 54), 12, MUTED)
	for i in range(3):
		var color := Color("f78b87") if i < state.hp else Color("303245")
		var x := 270.0 + i * 25
		draw_colored_polygon(PackedVector2Array([Vector2(x, 29), Vector2(x + 7, 24), Vector2(x + 14, 29), Vector2(x + 14, 34), Vector2(x + 7, 42), Vector2(x, 34)]), color)
	text_at("机体", Vector2(284, 59), 10, MUTED)
	text_at("%02d" % ceili(60 - state.elapsed), Vector2(418, 47), 34, Color.WHITE, 70, HORIZONTAL_ALIGNMENT_CENTER)
	text_at("SEC", Vector2(490, 46), 12, MUTED)
	text_at("火力  %d / 3" % state.level, Vector2(582, 42), 16, CYAN)
	text_at("击碎  %02d" % state.kills, Vector2(718, 42), 16, Color("edbb7d"))
	draw_rect(Rect2(24, 69, 912 * state.elapsed / 60.0, 2), CYAN)
	draw_rect(Rect2(0, 619, 960, 21), Color("091324"))
	text_at("WASD / 方向键移动       自动开火       ESC 暂停", Vector2(24, 634), 10, MUTED)
	text_at("每击碎8颗陨石掉落升级芯片", Vector2(660, 634), 10, MUTED)
	if state.phase == State.Phase.RUNNING: return
	draw_rect(Rect2(0, 72, 960, 547), Color(0.02, 0.04, 0.08, 0.78))
	draw_style_box(_panel(), Rect2(222, 149, 516, 355))
	text_at("A TINY SPACE SURVIVAL", Vector2(254, 188), 12, CYAN, 452, HORIZONTAL_ALIGNMENT_CENTER)
	var title: String = ["撑过60秒", "", "喘口气，继续飞", "漂亮，成功生还！", "机体损毁"] [state.phase]
	text_at(title, Vector2(254, 253), 39, Color.WHITE, 452, HORIZONTAL_ALIGNMENT_CENTER)
	var subtitle := "不用瞄准。保持移动。活着回来。"
	if state.phase == State.Phase.PAUSED: subtitle = "时间已冻结，准备好再继续"
	elif state.phase == State.Phase.WON: subtitle = "你坚持了60秒，击碎 %d 颗陨石" % state.kills
	elif state.phase == State.Phase.LOST: subtitle = "坚持 %.1f 秒 · 击碎 %d 颗陨石" % [state.elapsed, state.kills]
	text_at(subtitle, Vector2(254, 291), 17, MUTED, 452, HORIZONTAL_ALIGNMENT_CENTER)
	text_at("WASD / 方向键移动  ·  自动开火", Vector2(254, 345), 16, Color("c7d3e4"), 452, HORIZONTAL_ALIGNMENT_CENTER)
	text_at("躲开陨石，收集绿色芯片升级火力", Vector2(254, 375), 16, Color("c7d3e4"), 452, HORIZONTAL_ALIGNMENT_CENTER)
	var hint := "也可以按 ENTER 开始" if state.phase == State.Phase.READY else ("按 ESC 继续" if state.phase == State.Phase.PAUSED else "按 R 立即重开")
	text_at(hint, Vector2(254, 488), 11, MUTED, 452, HORIZONTAL_ALIGNMENT_CENTER)
func _panel() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0e1b2e")
	style.border_color = Color("315565")
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style
