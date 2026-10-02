extends Node2D
const State = preload("res://scripts/run_state.gd")
const Pilot = preload("res://scripts/player.gd")
const Gun = preload("res://scripts/weapon.gd")
const Spawn = preload("res://scripts/spawner.gd")
const Rock = preload("res://scripts/meteor.gd")
const Shot = preload("res://scripts/bullet.gd")
const Chip = preload("res://scripts/upgrade_pickup.gd")
const HeadsUp = preload("res://scripts/hud.gd")
var hud = HeadsUp.new()
var state = State.new()
var player = Pilot.new()
var weapon = Gun.new()
var spawner = Spawn.new()
var meteors: Array[Node2D] = []
var bullets: Array[Node2D] = []
var pickups: Array[Node2D] = []
var particles: Array[Dictionary] = []
var visual_time := 0.0
var damage_flash := 0.0
var held_keys: Dictionary = {}
func _ready() -> void:
	add_child(player)
	player.add_to_group("run_entities")
	player.reset()
	spawner.reset(-1)
	add_child(hud)
	hud.start_requested.connect(_request_start)
	hud.resume_requested.connect(func(): state.set_paused(false))
	hud.restart_requested.connect(_request_restart)
	state.changed.connect(hud.render_state.bind(state))
	hud.render_state(state)
func _request_start() -> void:
	if state.phase == State.Phase.READY: start_run()
func _request_restart() -> void:
	if state.phase in [State.Phase.WON, State.Phase.LOST]: start_run()
func start_run(seed_value: int = -1) -> void:
	for entity in meteors + bullets + pickups:
		entity.free()
	meteors.clear(); bullets.clear(); pickups.clear(); particles.clear()
	player.reset(); weapon.reset(); spawner.reset(seed_value); state.start()
	damage_flash = 0.0
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var code: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if event.pressed: held_keys[code] = true
		else: held_keys.erase(code)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER and state.phase == State.Phase.READY:
			start_run()
		elif event.keycode == KEY_R and state.phase in [State.Phase.WON, State.Phase.LOST]:
			start_run()
		elif event.keycode == KEY_ESCAPE:
			state.set_paused(state.phase == State.Phase.RUNNING)
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		held_keys.clear()
		state.set_paused(true)
func movement_input() -> Vector2:
	return Vector2(float(held_keys.has(KEY_D) or held_keys.has(KEY_RIGHT)) - float(held_keys.has(KEY_A) or held_keys.has(KEY_LEFT)), float(held_keys.has(KEY_S) or held_keys.has(KEY_DOWN)) - float(held_keys.has(KEY_W) or held_keys.has(KEY_UP)))
func add_entity(entity: Node2D, collection: Array[Node2D]) -> void:
	add_child(entity)
	entity.add_to_group("run_entities")
	collection.append(entity)
func _physics_process(delta: float) -> void:
	if state.phase == State.Phase.RUNNING:
		simulate(delta, movement_input())
	queue_redraw()
func simulate(delta: float, input: Vector2) -> void:
	if state.phase != State.Phase.RUNNING:
		return
	visual_time += delta
	damage_flash = maxf(0, damage_flash - delta)
	player.move(input, delta)
	for data in spawner.advance(delta, state.elapsed + delta, state.spawn_interval()):
		var rock = Rock.new()
		rock.setup(data.position, data.velocity, data.hp)
		add_entity(rock, meteors)
	for direction in weapon.advance(delta, state.level):
		var bullet = Shot.new()
		bullet.setup(player.position + Vector2(0, -23), direction)
		add_entity(bullet, bullets)
	for bullet in bullets: bullet.advance(delta)
	for rock in meteors: rock.advance(delta)
	for chip in pickups: chip.advance(delta)
	var hit_player := false
	for rock in meteors:
		if rock.dead: continue
		for bullet in bullets:
			if bullet.spent or rock.dead: continue
			if bullet.hits_moving_circle(rock.previous_position, rock.position, rock.radius):
				bullet.spent = true
				if rock.take_hit():
					burst(rock.position, Color("f4ae7f"), 12)
					if state.register_kill():
						var chip = Chip.new(); chip.setup(rock.position); add_entity(chip, pickups)
		if not rock.dead and player.position.distance_to(rock.position) < rock.radius + Pilot.RADIUS:
			rock.dead = true
			hit_player = true
			burst(rock.position, Color("f47f92"), 12)
	for chip in pickups:
		if not chip.expired and player.position.distance_to(chip.position) < 28 and chip.collect():
			state.collect_upgrade(); burst(chip.position, Color("79f8b8"), 18)
	var old_hp: int = state.hp
	state.step(delta, hit_player)
	if state.hp < old_hp: damage_flash = 0.22
	player.invulnerable = state.invulnerability_remaining > 0
	cleanup()
	for particle in particles:
		particle.position += particle.velocity * delta
		particle.life -= delta
	particles = particles.filter(func(p): return p.life > 0)
func cleanup() -> void:
	for i in range(meteors.size() - 1, -1, -1):
		if meteors[i].dead: meteors[i].free(); meteors.remove_at(i)
	for i in range(bullets.size() - 1, -1, -1):
		if bullets[i].spent or bullets[i].offscreen: bullets[i].free(); bullets.remove_at(i)
	for i in range(pickups.size() - 1, -1, -1):
		if pickups[i].expired: pickups[i].free(); pickups.remove_at(i)
func burst(origin: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		particles.append({"position": origin, "velocity": Vector2.from_angle(i * TAU / count) * (65 + i % 4 * 28), "life": 0.4, "color": color})
func _draw() -> void:
	for x in range(0, 960, 48):
		draw_line(Vector2(x, 70), Vector2(x, 640), Color(0.1, 0.35, 0.45, 0.12))
	for y in range(70, 640, 48):
		draw_line(Vector2(0, y), Vector2(960, y), Color(0.1, 0.35, 0.45, 0.12))
	for i in range(70):
		draw_circle(Vector2(fmod(i * 157.3, 940.0) + 10, fmod(i * 89.7 + visual_time * (8 + i % 3 * 5), 555.0) + 78), 0.8 + float(i % 2) * 0.6, Color(0.5, 0.7, 0.8, 0.3))
	for particle in particles:
		var color: Color = particle.color; color.a = particle.life / 0.4
		draw_circle(particle.position, 2.3, color)
	if damage_flash > 0: draw_rect(Rect2(0, 72, 960, 547), Color(0.8, 0.1, 0.2, damage_flash * 0.4))
