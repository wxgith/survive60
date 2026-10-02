class_name RunState
extends RefCounted
signal changed

enum Phase { READY, RUNNING, PAUSED, WON, LOST }
var phase: Phase = Phase.READY
var hp := 3
var elapsed := 0.0
var kills := 0
var level := 1
var invulnerability_remaining := 0.0

func start() -> void:
	phase = Phase.RUNNING
	hp = 3
	elapsed = 0.0
	kills = 0
	level = 1
	invulnerability_remaining = 0.0
	changed.emit()

func step(delta: float, hit_player: bool = false) -> void:
	if phase != Phase.RUNNING:
		return
	if hit_player and invulnerability_remaining <= 0.0:
		hp -= 1
		invulnerability_remaining = 1.0
		if hp <= 0:
			phase = Phase.LOST
			changed.emit()
			return
	else:
		invulnerability_remaining = maxf(0.0, invulnerability_remaining - delta)
	elapsed = minf(60.0, elapsed + delta)
	if elapsed >= 60.0:
		phase = Phase.WON
	changed.emit()

func set_paused(value: bool) -> void:
	if value and phase == Phase.RUNNING:
		phase = Phase.PAUSED
	elif not value and phase == Phase.PAUSED:
		phase = Phase.RUNNING
	changed.emit()

func register_kill() -> bool:
	if phase != Phase.RUNNING:
		return false
	kills += 1
	changed.emit()
	return level < 3 and kills % 8 == 0

func collect_upgrade() -> void:
	if phase == Phase.RUNNING:
		level = mini(3, level + 1)
		changed.emit()

func spawn_interval() -> float:
	return 1.0 if elapsed < 20.0 else (0.7 if elapsed < 40.0 else 0.45)
