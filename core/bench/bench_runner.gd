extends Node
## Messmodus (WP 4.5): spielt jedes Minispiel (erstes Format) mit vier Computergegnern je 20 s und
## misst echte Frametimes. Ergebnis mit Durchschnitt und 1-%-Tiefstwert nach `user://bench.txt`.
## Start: godot --path . -- --bench [--bench-seconds=20] [--quality=0|1|2]
## Exportiertes Spiel: Partypark.exe -- --bench   (Ergebnisse in docs/PERFORMANCE.md eintragen)
## VSync ist während der Messung aus, damit man Reserven über 60 fps sieht.

const OUTPUT: String = "user://bench.txt"
## Einschwingzeit pro Spiel, wird nicht gemessen (Shader-Kompilierung, Aufbau).
const WARMUP: float = 2.0

var seconds: float = 20.0
var results: Array[Dictionary] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var args: PackedStringArray = OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	for arg: String in args:
		if arg.begins_with("--bench-seconds="):
			seconds = maxf(1.0, float(arg.trim_prefix("--bench-seconds=")))
		elif arg.begins_with("--quality="):
			Settings.graphics_quality = clampi(int(arg.trim_prefix("--quality=")), 0, 2)
			Settings.apply_graphics()
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Settings.show_performance = true
	get_tree().current_scene.queue_free()
	await get_tree().process_frame
	var sandbox := MinigameSandbox.new()
	add_child(sandbox)
	for info: MinigameInfo in MinigameRegistry.infos:
		var format: int = info.formats[0]
		sandbox.start(info, format, Settings.cpu_difficulty, 9999.0)
		var times: PackedFloat32Array = []
		var elapsed: float = 0.0
		var last: int = Time.get_ticks_usec()
		var max_calls: int = 0
		while elapsed < WARMUP + seconds:
			await get_tree().process_frame
			var now: int = Time.get_ticks_usec()
			var frame_ms: float = float(now - last) / 1000.0
			last = now
			elapsed += frame_ms / 1000.0
			if elapsed > WARMUP:
				times.append(frame_ms)
				max_calls = maxi(max_calls, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
		var stats: Dictionary = PerfOverlay.frame_stats(times)
		stats["id"] = String(info.id)
		stats["name"] = info.display_name
		stats["draw_calls"] = max_calls
		results.append(stats)
		print("BENCH %-18s %6.1f fps  1%% tief %6.1f fps  %5.2f ms  Draw Calls max %d" % [info.id, stats["avg_fps"], stats["low_fps"], stats["avg_ms"], max_calls])
		sandbox.stop()
		await get_tree().process_frame
	_write()
	get_tree().quit(0)


func _write() -> void:
	var lines: PackedStringArray = []
	lines.append("Partypark Messmodus %s" % Time.get_datetime_string_from_system(false, true))
	lines.append("Version %s, Godot %s, %s" % [ProjectSettings.get_setting("application/config/version"), Engine.get_version_info()["string"], OS.get_name()])
	lines.append("Grafikkarte: %s" % RenderingServer.get_video_adapter_name())
	lines.append("Grafikstufe: %s, Fenster %s, %d s je Spiel, VSync aus" % [Settings.QUALITY_NAMES[Settings.graphics_quality], str(DisplayServer.window_get_size()), roundi(seconds)])
	lines.append("")
	lines.append("| Minispiel | Durchschnitt fps | 1 % tief fps | Frametime ms | Draw Calls max |")
	lines.append("|---|---|---|---|---|")
	for r: Dictionary in results:
		lines.append("| %s | %.1f | %.1f | %.2f | %d |" % [r["name"], r["avg_fps"], r["low_fps"], r["avg_ms"], r["draw_calls"]])
	var file := FileAccess.open(OUTPUT, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(lines) + "\n")
		file.close()
	print("BENCH: Ergebnis in %s" % ProjectSettings.globalize_path(OUTPUT))
