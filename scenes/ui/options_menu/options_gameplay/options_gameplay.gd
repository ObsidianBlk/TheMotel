extends Control

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _ignore_emit : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _slider_sense_x: HSlider = %SLIDER_SenseX
@onready var _slider_sense_y: HSlider = %SLIDER_SenseY
@onready var _check_invert_x: CheckButton = %CHECK_InvertX
@onready var _check_invert_y: CheckButton = %CHECK_InvertY


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	MSense.sensitivity_changed.connect(_on_msense_sensitivity_changed)
	_UpdateControls()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateControls() -> void:
	if _slider_sense_x != null:
		_slider_sense_x.set_value_no_signal(MSense.sensitivity_x * _slider_sense_x.max_value)
	if _slider_sense_y != null:
		_slider_sense_y.set_value_no_signal(MSense.sensitivity_y * _slider_sense_y.max_value)
	if _check_invert_x != null:
		_check_invert_x.set_pressed_no_signal(MSense.invert_x)
	if _check_invert_y != null:
		_check_invert_y.set_pressed_no_signal(MSense.invert_y)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_msense_sensitivity_changed(_mouse_sensitivity : Vector2) -> void:
	if not _ignore_emit:
		_UpdateControls()
	_ignore_emit = false

func _on_check_invert_x_toggled(toggled_on: bool) -> void:
	_ignore_emit = true
	MSense.invert_x = toggled_on

func _on_check_invert_y_toggled(toggled_on: bool) -> void:
	_ignore_emit = true
	MSense.invert_y = toggled_on

func _on_slider_sense_x_value_changed(value: float) -> void:
	_ignore_emit = true
	MSense.sensitivity_x = value / _slider_sense_x.max_value

func _on_slider_sense_y_value_changed(value: float) -> void:
	_ignore_emit = true
	MSense.sensitivity_y = value / _slider_sense_y.max_value
