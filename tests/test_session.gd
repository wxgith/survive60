extends RefCounted
func run(t) -> bool:
	if not FileAccess.file_exists("res://scripts/hud.gd"):
		t.check(false, "Missing playable HUD")
		return false
	var script = load("res://scripts/main.gd")
	if not script.can_instantiate():
		t.check(false, "main script compiles")
		return false
	var game = load("res://scenes/main.tscn").instantiate()
	t.root.add_child(game)
	game.set_physics_process(false)
	for i in range(10): game.start_run(1234)
	t.check(game.state.hp == 3 and game.state.level == 1 and game.state.elapsed == 0.0, "ten restarts reset state")
	t.check(t.get_nodes_in_group("run_entities").size() == 1, "ten restarts leave only one player")
	game.simulate(0.22, Vector2.ZERO)
	t.check(game.bullets.size() == 1, "running scene fires")
	game.state.invulnerability_remaining = 0.7
	var chip = load("res://scripts/upgrade_pickup.gd").new()
	chip.setup(Vector2(100, 100)); game.add_entity(chip, game.pickups)
	game.state.set_paused(true)
	var before = game.bullets[0].position
	game.simulate(10.0, Vector2.RIGHT)
	t.check(game.state.elapsed == 0.22 and game.state.invulnerability_remaining == 0.7, "paused scene freezes timers")
	t.check(chip.age == 0.0 and game.bullets[0].position == before, "paused scene freezes entities")
	game.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	t.check(game.state.phase == game.State.Phase.PAUSED, "focus return stays paused")
	game.start_run(9)
	game.state.hp = 1; game.state.elapsed = 59.99
	var rock = load("res://scripts/meteor.gd").new()
	rock.setup(game.player.position, Vector2.ZERO, 2); game.add_entity(rock, game.meteors)
	game.simulate(0.02, Vector2.ZERO)
	t.check(game.state.phase == game.State.Phase.LOST, "real scene lethal at 60 loses")
	game.start_run(3)
	var crossed_rock = load("res://scripts/meteor.gd").new()
	crossed_rock.setup(Vector2(100, 100), Vector2.ZERO, 1)
	game.add_entity(crossed_rock, game.meteors)
	var crossing_bullet = load("res://scripts/bullet.gd").new()
	crossing_bullet.setup(Vector2(100, 200), Vector2.UP)
	game.add_entity(crossing_bullet, game.bullets)
	game.simulate(0.3, Vector2.ZERO)
	t.check(game.state.kills == 1 and game.meteors.is_empty(), "offscreen crossing bullet resolves sweep before cleanup")
	game.start_run(3)
	var moving_rock = load("res://scripts/meteor.gd").new()
	moving_rock.setup(Vector2(65, 250), Vector2(130, 190), 1)
	game.add_entity(moving_rock, game.meteors)
	var meeting_bullet = load("res://scripts/bullet.gd").new()
	meeting_bullet.setup(Vector2(100, 500), Vector2.UP)
	game.add_entity(meeting_bullet, game.bullets)
	game.simulate(0.5, Vector2.ZERO)
	t.check(game.state.kills == 1 and game.meteors.is_empty(), "relative sweep catches moving meteor crossing bullet")
	game.start_run(4)
	for i in range(3601):
		# External test pilot clears collisions, keeping production movement/timers/spawns intact.
		for meteor in game.meteors: meteor.position.x = -200
		game.simulate(1.0 / 60.0, Vector2.ZERO)
	t.check(game.state.phase == game.State.Phase.WON and game.state.elapsed == 60.0, "full 60-second scene simulation wins")
	var hp_before: int = game.state.hp
	game.state.step(1.0, true)
	t.check(game.state.hp == hp_before, "finished game ignores collision")
	game.start_run(15)
	game.simulate(5.0, Vector2.ZERO)
	game.start_run(15)
	t.check(game.bullets.is_empty() and game.meteors.is_empty() and game.pickups.is_empty() and game.particles.is_empty(), "restart clears all transient objects")
	game.start_run(5)
	var key := InputEventKey.new(); key.keycode = KEY_D; key.physical_keycode = KEY_D; key.pressed = true
	game._unhandled_input(key)
	t.check(game.movement_input() == Vector2.RIGHT, "physical D input works")
	game.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	t.check(game.movement_input() == Vector2.ZERO, "focus loss clears held movement")
	var idle_wins := 0
	for seed_value in range(12):
		game.start_run(seed_value)
		for frame in range(3601):
			game.simulate(1.0 / 60.0, Vector2.ZERO)
			if game.state.phase != game.State.Phase.RUNNING: break
		if game.state.phase == game.State.Phase.WON: idle_wins += 1
	t.check(idle_wins <= 6, "standing still is not the dominant survival strategy")
	game.free()
	return true
