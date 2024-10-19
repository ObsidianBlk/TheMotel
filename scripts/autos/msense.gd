extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal sensitivity_changed(mouse_sensitivity : Vector2)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const MIN_SENSITIVITY : float = 0.01
const MAX_SENSITIVITY : float = 1.2

const DEFAULT_SENSITIVITY_X : float = 0.5
const DEFAULT_SENSITIVITY_Y : float = 0.5
const DEFAULT_INVERT_X : bool = false
const DEFAULT_INVERT_Y : bool = false

const SETTINGS_SECTION : String = "MOUSE"
const SETTINGS_KEY_SENSITIVITY_X : String = "SensX"
const SETTINGS_KEY_SENSITIVITY_Y : String = "SensY"
const SETTINGS_KEY_INVERT_X : String = "InvX"
const SETTINGS_KEY_INVERT_Y : String = "InvY"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
var sensitivity_x : float:		set=set_sensitivity_x, get=get_sensitivity_x
var sensitivity_y : float:		set=set_sensitivity_y, get=get_sensitivity_y
var invert_x : bool:			set=set_invert_x, get=get_invert_x
var invert_y : bool:			set=set_invert_y, get=get_invert_y

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
# This is a percentage value (0.0 to 1.0) for both axii
var _sensitivity : Vector2 = Vector2(0.5, 0.5)
var _inv : Array[bool] = [false, false]
var _allow_emit : bool = true

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_sensitivity_x(sx : float) -> void:
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_SENSITIVITY_X, clampf(sx, 0.0, 1.0))
	#_sensitivity.x = clampf(sx, 0.0, 1.0)
	#_EmitUpdatedSens()

func get_sensitivity_x() -> float:
	return _sensitivity.x

func set_sensitivity_y(sy : float) -> void:
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_SENSITIVITY_Y, clampf(sy, 0.0, 1.0))
	#_sensitivity.y = clampf(sy, 0.0, 1.0)
	#_EmitUpdatedSens()

func get_sensitivity_y() -> float:
	return _sensitivity.y

func set_invert_x(i : bool) -> void:
	if _inv[0] != i:
		Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_INVERT_X, i)
		#_inv[0] = i
		#_EmitUpdatedSens()

func get_invert_x() -> bool:
	return _inv[0]

func set_invert_y(i : bool) -> void:
	if _inv[1] != i:
		Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_INVERT_Y, i)
		#_inv[1] = i
		#_EmitUpdatedSens()

func get_invert_y() -> bool:
	return _inv[1]

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Settings.reset.connect(_on_settings_reset)
	Settings.loaded.connect(_on_settings_loaded)
	Settings.value_changed.connect(_on_settings_value_changed)
	_UpdateFromSettings()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateFromSettings() -> void:
	var val : Variant = Settings.get_value(SETTINGS_SECTION, SETTINGS_KEY_SENSITIVITY_X, DEFAULT_SENSITIVITY_X)
	if typeof(val) == TYPE_FLOAT:
		_sensitivity.x = clampf(val, 0.0, 1.0)
	
	val = Settings.get_value(SETTINGS_SECTION, SETTINGS_KEY_SENSITIVITY_Y, DEFAULT_SENSITIVITY_Y)
	if typeof(val) == TYPE_FLOAT:
		_sensitivity.y = clampf(val, 0.0, 1.0)
	
	val = Settings.get_value(SETTINGS_SECTION, SETTINGS_KEY_INVERT_X, DEFAULT_INVERT_X)
	if typeof(val) == TYPE_BOOL:
		_inv[0] = val
	
	val = Settings.get_value(SETTINGS_SECTION, SETTINGS_KEY_INVERT_Y, DEFAULT_INVERT_Y)
	if typeof(val) == TYPE_BOOL:
		_inv[1] = val
	
	_EmitUpdatedSens()


func _EmitUpdatedSens() -> void:
	sensitivity_changed.emit(get_sensitivity_vector())

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_sensitivity_vector() -> Vector2:
	var d : float = MAX_SENSITIVITY - MIN_SENSITIVITY
	return Vector2(
		(MIN_SENSITIVITY + (d * _sensitivity.x)) * (-1.0 if _inv[0] else 1.0),
		(MIN_SENSITIVITY + (d * _sensitivity.y)) * (-1.0 if _inv[1] else 1.0)
	)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_settings_reset() -> void:
	_allow_emit = false
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_SENSITIVITY_X, DEFAULT_SENSITIVITY_X)
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_SENSITIVITY_Y, DEFAULT_SENSITIVITY_Y)
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_INVERT_X, DEFAULT_INVERT_X)
	Settings.set_value(SETTINGS_SECTION, SETTINGS_KEY_INVERT_Y, DEFAULT_INVERT_Y)
	_EmitUpdatedSens()

func _on_settings_loaded() -> void:
	_UpdateFromSettings()

func _on_settings_value_changed(section : String, key : String, value : Variant) -> void:
	if section != SETTINGS_SECTION: return
	match key:
		SETTINGS_KEY_SENSITIVITY_X:
			if typeof(value) == TYPE_FLOAT:
				_sensitivity.x = clampf(value, 0.0, 1.0)
		SETTINGS_KEY_SENSITIVITY_Y:
			if typeof(value) == TYPE_FLOAT:
				_sensitivity.y = clampf(value, 0.0, 1.0)
		SETTINGS_KEY_INVERT_X:
			if typeof(value) == TYPE_BOOL:
				_inv[0] = value
		SETTINGS_KEY_INVERT_Y:
			if typeof(value) == TYPE_BOOL:
				_inv[1] = value
	
	if _allow_emit:
		_EmitUpdatedSens()
