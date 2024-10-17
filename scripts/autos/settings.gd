extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal reset()
signal loaded()
signal saved()
signal section_removed(section : String)
signal value_removed(section : String, key : String)
signal value_changed(section : String, key : String, value : Variant)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const CONFIG_FILE_PATH_DEFAULT : String = "user://game_settings.cfg"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active_config_path : String = ""
var _conf : ConfigFile = null
var _dirty : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func is_dirty() -> bool:
	return _dirty


func request_reset() -> void:
	if _conf == null:
		_conf = ConfigFile.new()
	reset.emit()

func get_active_config_filepath() -> String:
	return CONFIG_FILE_PATH_DEFAULT if _active_config_path.is_empty() else _active_config_path

func load(config_path : String = "") -> int:
	if config_path.is_empty():
		config_path = CONFIG_FILE_PATH_DEFAULT if _active_config_path.is_empty() else _active_config_path
	
	var c : ConfigFile = ConfigFile.new()
	var res : int = c.load(config_path)
	if res != OK:
		return res
	
	if _conf != null:
		_conf = null
	_active_config_path = config_path
	_conf = c
	_dirty = false
	loaded.emit()
	return OK

func reload() -> int:
	if _active_config_path.is_empty():
		return ERR_FILE_NOT_FOUND
	_conf = null
	return self.load(_active_config_path)

func save() -> int:
	if _conf == null: return ERR_UNCONFIGURED
	if _active_config_path.is_empty():
		_active_config_path = CONFIG_FILE_PATH_DEFAULT
		
	var res : int = _conf.save(_active_config_path)
	if res != OK:
		return res
	_dirty = false
	saved.emit()
	return OK

func has_section(section : String) -> bool:
	if _conf == null: return false
	return _conf.has_section(section)

func has_section_key(section : String, key : String) -> bool:
	if _conf == null: return false
	return _conf.has_section_key(section, key)

func get_value(section : String, key : String, default : Variant = null) -> Variant:
	if _conf == null: return default
	return _conf.get_value(section, key, default)

func set_value(section : String, key : String, value : Variant) -> void:
	if _conf == null: return
	var sec_key_existed : bool = _conf.has_section_key(section, key)
	var sec_existed : bool = _conf.has_section(section)
	
	_conf.set_value(section, key, value)
	_dirty = true
	
	if sec_key_existed and not _conf.has_section_key(section, key):
		value_removed.emit(section, key)
	if sec_existed and not _conf.has_section(section):
		section_removed.emit(section)

	if _conf.has_section_key(section, key):
		value_changed.emit(section, key, value)

func erase_section(section : String) -> void:
	if _conf == null: return
	if _conf.has_section(section):
		_conf.erase_section(section)
		_dirty = true
		section_removed.emit(section)

func erase_section_key(section : String, key : String) -> void:
	if _conf == null: return
	if _conf.has_section_key(section, key):
		_conf.erase_section_key(section, key)
		_dirty = true
		value_removed.emit(section, key)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
