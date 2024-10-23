extends PanelContainer


# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const SETTINGS_SECTION : String = "GRAPHICS"
const SETTINGS_KEY_FULLSCREEN : String = "fullscreen"
const SETTINGS_KEY_GI : String = "sdfgi"
const SETTINGS_KEY_VF : String = "volumetric_fog"

const DEFAULT_FULLSCREEN : bool = false
const DEFAULT_GI : bool = true
const DEFAULT_VF : bool = true

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _check_fullscreen: CheckButton = %CHECK_Fullscreen
@onready var _check_gi: CheckButton = %CHECK_GI
@onready var _check_volumetric_fog: CheckButton = %CHECK_VolumetricFog

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Settings.reset.connect(_on_settings_reset)
	Settings.loaded.connect(_on_settings_loaded)
	Settings.value_changed.connect(_on_settings_value_changed)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetSettingsValue(key : String) -> bool:
	var default : bool = false
	match key:
		SETTINGS_KEY_FULLSCREEN:
			default = DEFAULT_FULLSCREEN
		SETTINGS_KEY_GI:
			default = DEFAULT_GI
		SETTINGS_KEY_VF:
			default = DEFAULT_VF
	var v : Variant = Settings.get_value(SETTINGS_SECTION, key, default)
	if typeof(v) == TYPE_BOOL:
		return v
	return default

func _ResetFromSettings() -> void:
	_check_fullscreen.button_pressed = _GetSettingsValue(SETTINGS_KEY_FULLSCREEN)
	_check_gi.button_pressed = _GetSettingsValue(SETTINGS_KEY_GI)
	_check_volumetric_fog.button_pressed = _GetSettingsValue(SETTINGS_KEY_VF)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_settings_reset() -> void:
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_FULLSCREEN, DEFAULT_FULLSCREEN)
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_GI, DEFAULT_GI)
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_VF, DEFAULT_VF)

func _on_settings_loaded() -> void:
	_ResetFromSettings()

func _on_settings_value_changed(section : String, key : String, value : Variant) -> void:
	if section != SETTINGS_SECTION or typeof(value) != TYPE_BOOL: return
	match key:
		SETTINGS_KEY_FULLSCREEN:
			_check_fullscreen.button_pressed = value
			var mode : int = DisplayServer.WINDOW_MODE_FULLSCREEN if value == true else DisplayServer.WINDOW_MODE_WINDOWED
			DisplayServer.window_set_mode(mode)
		SETTINGS_KEY_GI:
			_check_gi.button_pressed = value
		SETTINGS_KEY_VF:
			_check_volumetric_fog.button_pressed = value

func _on_check_fullscreen_toggled(toggled_on: bool) -> void:
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_FULLSCREEN, toggled_on)

func _on_check_gi_toggled(toggled_on: bool) -> void:
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_GI, toggled_on)

func _on_check_volumetric_fog_toggled(toggled_on: bool) -> void:
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_VF, toggled_on)
