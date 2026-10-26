class_name GameLog
extends Node
## Zentrales, optionales Logging-System für Partypark.
## Kann über Kommandozeilenargumente (--verbose, --log, --log-level=...) gesteuert werden.
## Schreibt optional und gepuffert in user://partypark.log.

enum Level { DEBUG = 0, INFO = 1, WARN = 2, ERROR = 3, NONE = 4 }

const LEVEL_NAMES: Array[String] = ["DEBUG", "INFO", "WARN", "ERROR", "NONE"]

var current_level: int = Level.INFO
var log_to_file: bool = true
var log_file_path: String = "user://partypark.log"

var _file: FileAccess = null
var _start_msec: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_start_msec = Time.get_ticks_msec()
	_parse_cmdline_args()
	_init_file()
	info("SYS", "Partypark Logger gestartet (Level: %s, Datei: %s)" % [LEVEL_NAMES[current_level], log_file_path if log_to_file else "Aus"])


func _exit_tree() -> void:
	if _file != null:
		_file.flush()
		_file.close()
		_file = null


func _parse_cmdline_args() -> void:
	var args: PackedStringArray = OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())

	if OS.is_debug_build():
		current_level = Level.DEBUG

	for arg: String in args:
		if arg == "--verbose" or arg == "-v" or arg == "--log":
			current_level = Level.DEBUG
		elif arg == "--quiet" or arg == "-q":
			current_level = Level.WARN
		elif arg.begins_with("--log-level="):
			var val: String = arg.trim_prefix("--log-level=").to_upper()
			match val:
				"DEBUG": current_level = Level.DEBUG
				"INFO": current_level = Level.INFO
				"WARN": current_level = Level.WARN
				"ERROR": current_level = Level.ERROR
				"NONE": current_level = Level.NONE
		elif arg == "--no-log-file":
			log_to_file = false


func _init_file() -> void:
	if not log_to_file:
		return
	_file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if _file != null:
		var dt: Dictionary = Time.get_datetime_dict_from_system()
		_file.store_line("=== Partypark Log %04d-%02d-%02d %02d:%02d:%02d ===" % [
			dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second
		])
		_file.flush()


func log_msg(level: int, category: String, message: String) -> void:
	if level < current_level or current_level == Level.NONE:
		return

	var elapsed_ms: int = Time.get_ticks_msec() - _start_msec
	var sec: int = elapsed_ms / 1000
	var ms: int = elapsed_ms % 1000
	var tag: String = LEVEL_NAMES[level]
	var formatted: String = "[%03d.%03ds] [%s] [%-6s] %s" % [sec, ms, tag, category, message]

	match level:
		Level.DEBUG:
			print(formatted)
		Level.INFO:
			print(formatted)
		Level.WARN:
			push_warning(formatted)
		Level.ERROR:
			printerr(formatted)

	if _file != null:
		_file.store_line(formatted)
		_file.flush()


func debug(category: String, message: String) -> void:
	log_msg(Level.DEBUG, category, message)


func info(category: String, message: String) -> void:
	log_msg(Level.INFO, category, message)


func warn(category: String, message: String) -> void:
	log_msg(Level.WARN, category, message)


func error(category: String, message: String) -> void:
	log_msg(Level.ERROR, category, message)
