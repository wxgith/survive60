extends SceneTree
var failures: Array[String] = []
var checks := 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)
		printerr("FAIL: " + label)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	for file in ["test_core.gd", "test_combat.gd", "test_session.gd"]:
		var path: String = "res://tests/" + file
		if not FileAccess.file_exists(path):
			check(false, "Missing required test suite: " + file)
		else:
			var test_script = load(path)
			if test_script == null or not test_script.can_instantiate():
				check(false, "Load " + file)
			else:
				var completed = await test_script.new().run(self)
				check(completed == true, file + " completed without script interruption")
	print("%s: %d checks, %d failures" % ["ALL TESTS PASSED" if failures.is_empty() else "TESTS FAILED", checks, failures.size()])
	quit(0 if failures.is_empty() else 1)
