extends Node


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
#const DEFAULT_LEVEL_PATH : String = "res://scenes/test_scene/test_scene.tscn"
const DEFAULT_LEVEL_PATH : String = "res://scenes/the_motel/the_motel.tscn"

const DICT_SCENE : StringName = &"scene"
const DICT_LOADING : StringName = &"loading"

const AUDIO_BUS_AMBIENT : StringName = &"Ambient_Outdoor"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var pause_menu : StringName = &""
@export var load_screen : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _loaded_scenes : Dictionary = {}
var _active_level : Node3D = null
var _active_level_src : String = ""

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _ui: UILayer = %UI


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	get_tree().paused = true
	Clock24.set_seconds_per_minute(1.0)
	_ui.register_action_handler(UIAT.ACTION_QUIT_APPLICATION, _UIQuitApplication)
	_ui.register_action_handler(UIAT.ACTION_START_SINGLEPLAYER, _UIStartGame)
	_ui.register_action_handler(UIAT.ACTION_QUIT_GAME, _UIQuitGame)
	_ui.register_action_handler(UIAT.ACtION_RESUME_GAME, _UIResumeGame)
	_LoadSettings()

func _process(_delta: float) -> void:
	TRLoad.update_queue()

func _input(event: InputEvent) -> void:
	if _active_level != null and not get_tree().paused:
		if event.is_action_pressed("ui_cancel"):
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Clock24.enable(false)
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

func _HasScene(src : String) -> bool:
	return src in _loaded_scenes

func _IsSceneLoaded(src : String) -> bool:
	if src in _loaded_scenes:
		return _loaded_scenes[src][DICT_SCENE] != null
	return false

func _IsSceneLoading(src : String) -> bool:
	if src in _loaded_scenes:
		return _loaded_scenes[src][DICT_LOADING]
	return false

func _ThreadedLevelLoadCallback(scene : Resource, progress : float, status : int, src : String) -> void:
	if status != OK:
		_loaded_scenes.erase(src)
		printerr("Error while loading level \"", src, "\"! Returning to main menu.")
		_UIQuitGame()
		return
	
	if scene == null:
		_ui.call_action(UIAT.ACTION_UPDATE_LOAD_PROGRESS, [progress])
	else:
		if scene is PackedScene:
			_loaded_scenes[src][DICT_LOADING] = false
			_loaded_scenes[src][DICT_SCENE] = scene
			var lvl : Level = _CreateLevelInstance(src)
			if lvl == null:
				printerr("ERROR: PackedScene, \"", src, "\", is not a Level instance.")
				_loaded_scenes.erase(src)
			else:
				_ui.close_all_ui()
				var res : int = _CreateSceneAsLevel(src)
				if res != OK:
					_UIQuitGame()
		else:
			_loaded_scenes.erase(src)
			printerr("ERROR: Loaded resource \"", src, "\" is not a PackedScene.")
			_UIQuitGame()


func _LoadScene(src : String) -> int:
	if _HasScene(src):
		if _IsSceneLoaded(src): return ERR_ALREADY_EXISTS
		if _IsSceneLoading(src): return ERR_BUSY
		return ERR_BUG
	
	_loaded_scenes[src] = {
		DICT_SCENE: null,
		DICT_LOADING: true
	}
	
	TRLoad.request_resource(src, _ThreadedLevelLoadCallback.bind(src))
	return OK

func _CreateLevelInstance(src : String) -> Level:
	if src in _loaded_scenes:
		if _loaded_scenes[src][DICT_SCENE] != null:
			var lvl : Variant = _loaded_scenes[src][DICT_SCENE].instantiate()
			if lvl is Level:
				return lvl
			lvl.queue_free()
	return null

func _CreateSceneAsLevel(src : String) -> int:
	if not src in _loaded_scenes: return ERR_FILE_NOT_FOUND
	if _loaded_scenes[src][DICT_LOADING] == true: return ERR_BUSY
	if _loaded_scenes[src][DICT_SCENE] == null: return ERR_BUG
	
	var lvl : Level = _CreateLevelInstance(src)
	if lvl == null:
		return ERR_FILE_UNRECOGNIZED
	
	var idx : int = AudioServer.get_bus_index(AUDIO_BUS_AMBIENT)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(0.0))
	
	if _active_level != null:
		_CloseActiveLevel()
	
	lvl.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child.call_deferred(lvl)
	
	_active_level = lvl
	_active_level_src = src
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Clock24.enable(true)
	get_tree().paused = false
	
	return OK


# ------------------------------------------------------------------------------
# UI Action Methods
# ------------------------------------------------------------------------------
func _UIQuitApplication() -> void:
	get_tree().quit()

func _UIQuitGame() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_CloseActiveLevel()
	_ui.close_all_ui()
	_ui.open_default_ui()

func _UIStartGame() -> void:
	get_tree().paused = true
	var res : int = _LoadScene(DEFAULT_LEVEL_PATH)
	if res == ERR_ALREADY_EXISTS:
		res = _CreateSceneAsLevel(DEFAULT_LEVEL_PATH)
		if res != OK:
			_UIQuitGame()
	elif res != OK:
		_UIQuitGame()
	elif not load_screen.is_empty():
		_ui.open_ui(load_screen)

func _UIResumeGame() -> void:
	if _active_level != null:
		_ui.close_all_ui()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Clock24.enable(true)
		get_tree().paused = false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
