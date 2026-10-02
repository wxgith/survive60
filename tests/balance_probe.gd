extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game); game.set_physics_process(false)
	var idle_wins := 0
	var moving_wins := 0
	for mode in range(2):
		for seed_value in range(12):
			game.start_run(seed_value)
			for i in range(3601):
				var input := Vector2.ZERO
				if mode == 1:
					var target := Vector2(480 + sin(i / 60.0 * 0.85) * 350, 530)
					input = (target - game.player.position).limit_length()
				game.simulate(1.0/60, input)
				if game.state.phase != game.State.Phase.RUNNING: break
			var won: bool = game.state.phase == game.State.Phase.WON
			if mode == 0 and won: idle_wins += 1
			if mode == 1 and won: moving_wins += 1
			print("%s seed=%d time=%.1f hp=%d result=%s" % ["idle" if mode == 0 else "moving", seed_value, game.state.elapsed, game.state.hp, "win" if won else "lose"])
	print("BALANCE idle_wins=%d/12 moving_wins=%d/12" % [idle_wins, moving_wins])
	game.free(); quit(0)
