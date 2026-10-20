extends Node
## Spielt jedes Minispiel in jedem seiner Formate einmal komplett mit vier Computergegnern
## (ohne Menüs, über MinigameSandbox) und prüft, dass es ein Ergebnis meldet.
## Start: godot --headless --path . --fixed-fps 60 -- --smoke-games [--game=<id>] [--short] [--shots=<ordner>]
## Minispiele können `debug_summary() -> String` anbieten; der Text wird mit ausgegeben.

var _failures: int = 0
var _checks: int = 0
var _only: String = ""
var _short: bool = false
var _shot_dir: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--game="):
			_only = arg.trim_prefix("--game=")
		elif arg == "--short":
			_short = true
		elif arg.begins_with("--shots="):
			_shot_dir = arg.trim_prefix("--shots=")
	_run.call_deferred()


func _run() -> void:
	print("SMOKE GAMES: Start")
	# Leere Szene, damit kein Menü mitläuft
	get_tree().current_scene.queue_free()
	await get_tree().process_frame
	var sandbox := MinigameSandbox.new()
	add_child(sandbox)
	for info: MinigameInfo in MinigameRegistry.infos:
		if _only != "" and String(info.id) != _only:
			continue
		for format: int in info.formats:
			var limit: float = 20.0 if _short else -1.0
			sandbox.start(info, format, Settings.cpu_difficulty, limit, 12345)
			var max_time: float = (limit if limit > 0.0 else sandbox.minigame.time_limit) + 5.0
			var frames: int = 0
			var shot_taken: bool = false
			while sandbox.running and float(frames) / 60.0 < max_time:
				await get_tree().physics_frame
				frames += 1
				if _shot_dir != "" and not shot_taken and frames == 60 * 8:
					shot_taken = true
					await _shot("%s_%d" % [info.id, format])
			var summary: String = ""
			if sandbox.minigame != null and sandbox.minigame.has_method("debug_summary"):
				summary = "  [%s]" % String(sandbox.minigame.call("debug_summary"))
			var label: String = "%s (%s)" % [info.display_name, TeamFormat.display_name(format)]
			_check(sandbox.result != null, "%s endet mit Ergebnis nach %d s%s" % [label, frames / 60, summary])
			sandbox.stop()
			await get_tree().physics_frame
	# Partikel-Obergrenze (Leistungsbudget): viele Stöße auf einmal
	var before: int = Fx.skipped_bursts
	for i: int in 20:
		for kind: StringName in Fx.BURSTS:
			Fx.burst(kind, Vector3.ZERO)
	_check(Fx.live_particles() <= Fx.MAX_LIVE_PARTICLES, "Partikel-Obergrenze %d hält (%d lebend, Pools %d)" % [Fx.MAX_LIVE_PARTICLES, Fx.live_particles(), Fx.pool_capacity()])
	_check(Fx.skipped_bursts > before, "überzählige Partikel-Stöße werden ausgelassen")
	Fx.clear()
	# Wackeln: Trauma wird angenommen
	var cam := Camera3D.new()
	add_child(cam)
	cam.current = true
	Fx.shake(Fx.SHAKE_STRONG)
	_check(Fx.current_shake() > 0.5, "Kamera-Wackeln nimmt Trauma an")
	cam.queue_free()
	_check(Sfx.missing.is_empty(), "alle Geräusche vorhanden %s" % ("" if Sfx.missing.is_empty() else str(Sfx.missing)))
	_check(_only == "none" or Sfx.played_count > 0, "Geräusche wurden abgespielt (%d, gedrosselt %d)" % [Sfx.played_count, Sfx.throttled_count])
	print("SMOKE GAMES: %d von %d Prüfungen bestanden" % [_checks - _failures, _checks])
	print("SMOKE GAMES: %s" % ("OK" if _failures == 0 else "FEHLER"))
	get_tree().quit(0 if _failures == 0 else 1)


func _check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("  ok    %s" % label)
	else:
		_failures += 1
		print("  FEHLER %s" % label)


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	if image == null:
		return
	DirAccess.make_dir_recursive_absolute(_shot_dir)
	image.save_png("%s/%s.png" % [_shot_dir, name])
