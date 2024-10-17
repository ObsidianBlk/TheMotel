extends Node


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const DEFAULT_LEVEL_PATH : String = "res://scenes/test_scene/test_scene.tscn"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var pause_menu : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active_level_src : String = ""
var _active_level : Node3D = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _ui: UILayer = %UI


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	get_tree().paused = true
	_ui.register_action_handler(UIAT.ACTION_QUIT_APPLICATION, _UIQuitApplication)
	_ui.register_action_handler(UIAT.ACTION_START_SINGLEPLAYER, _UIStartGame)
	_ui.register_action_handler(UIAT.ACTION_QUIT_GAME, _UIQuitGame)
	_ui.register_action_handler(UIAT.ACtION_RESUME_GAME, _UIResumeGame)
	_LoadSettings()

func _input(event: InputEvent) -> void:
	if _active_level != null and not get_tree().paused:
		if event.is_action_pressed("ui_cancel"):
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if pause_menu.is_empty():
				_ui.open_default_ui()
			else:
				_ui.open_ui(pause_menu)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _LoadSettings() -> void:
	if Settings.load() != OK:
		Settings.request_reset()
		Settings.save()

func _CloseActiveLevel() -> void:
	if _active_level == null: return
	remove_child(_active_level)
	_active_level.queue_free()
	_active_level = null
	_active_level_src = ""

func _LoadLevel(src : String) -> int:
	if src == _active_level_src: return OK
	var scene : Variant = load(src)
	if scene is PackedScene:
		var level : Variant = scene.instantiate()
		if level is Level:
			_active_level = level
			_active_level_src = src
			_active_level.process_mode = Node.PROCESS_MODE_PAUSABLE
			add_child(_active_level)
			return OK
		return ERR_CONNECTION_ERROR
	return ERR_FILE_UNRECOGNIZED

func _LevelInit() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ------------------------------------------------------------------------------
# UI Action Methods
# ------------------------------------------------------------------------------
func _UIQuitApplication() -> void:
	get_tree().quit()

func _UIQuitGame() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_CloseActiveLevel()
	_ui.open_default_ui()

func _UIStartGame() -> void:
	get_tree().paused = true
	var res : int = _LoadLevel(DEFAULT_LEVEL_PATH)
	if res == OK or _active_level != null:
		_ui.close_all_ui()
		get_tree().paused = false
		if res == OK:
			_LevelInit()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_ui.open_default_ui()

func _UIResumeGame() -> void:
	if _active_level != null:
		_ui.close_all_ui()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
