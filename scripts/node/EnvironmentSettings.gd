extends Node
class_name EnvironmentSettings


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const SETTINGS_SECTION : String = "GRAPHICS"
const SETTINGS_KEY_GI : String = "sdfgi"
const SETTINGS_KEY_VF : String = "volumetric_fog"

const DEFAULT_GI : bool = true
const DEFAULT_VF : bool = true

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _env : WorldEnvironment = null


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Settings.loaded.connect(_on_settings_loaded)
	Settings.value_changed.connect(_on_settings_value_changed)
	_UpdateFromSettings()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetEnv() -> WorldEnvironment:
	if _env == null:
		var n : Node = get_parent()
		if n is WorldEnvironment:
			_env = n
			_env.process_mode = PROCESS_MODE_ALWAYS
	return _env

func _GetSettingsValue(key : String) -> bool:
	var default : bool = false
	match key:
		SETTINGS_KEY_GI:
			default = DEFAULT_GI
		SETTINGS_KEY_VF:
			default = DEFAULT_VF
	var v : Variant = Settings.get_value(SETTINGS_SECTION, key, default)
	if typeof(v) == TYPE_BOOL:
		return v
	return default

func _UpdateFromSettings() -> void:
	var env : WorldEnvironment = _GetEnv()
	if env == null: return
	if env.environment == null: return
	env.environment.sdfgi_enabled = _GetSettingsValue(SETTINGS_KEY_GI)
	env.environment.volumetric_fog_enabled = _GetSettingsValue(SETTINGS_KEY_VF)

# ------------------------------------------------------------------------------
# Handler Methods
# ----------------------------------------const DEFAULT_FULLSCREEN : bool = false--------------------------------------
func _on_settings_loaded() -> void:
	_UpdateFromSettings()

func _on_settings_value_changed(section : String, key : String, value : Variant) -> void:
	if section != SETTINGS_SECTION or typeof(value) != TYPE_BOOL: return
	
	var env : WorldEnvironment = _GetEnv()
	if env == null: return
	if env.environment == null: return
	
	match key:
		SETTINGS_KEY_GI:
			env.environment.sdfgi_enabled = value
		SETTINGS_KEY_VF:
			env.environment.volumetric_fog_enabled = value
