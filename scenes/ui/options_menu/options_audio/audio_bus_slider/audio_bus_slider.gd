@tool
extends Control


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var audio_bus : StringName = &"":			set=set_audio_bus
@export var label_text : String = "Audio Volume":	set=set_label_text
@export var min_label_size: int = 0:				set=set_min_label_size

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _lbl_bus_name: Label = %LBL_BusName
@onready var _check_bus_active: CheckButton = %CHECK_BusActive
@onready var _slider_volume: HSlider = %SLIDER_Volume


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_audio_bus(ab : StringName) -> void:
	if audio_bus != ab:
		audio_bus = ab
		if not Engine.is_editor_hint():
			_UpdateAudioBusVolume()

func set_label_text(t : String) -> void:
	label_text = t
	_UpdateLabel()

func set_min_label_size(s : int) -> void:
	if s >= 0:
		min_label_size = s
		_UpdateLabel()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateLabel()
	if not Engine.is_editor_hint():
		_UpdateAudioBusVolume()
		AVC.bus_volume_changed.connect(_on_avc_bus_volume_changed)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateAudioBusVolume() -> void:
	if not audio_bus.is_empty() and not Engine.is_editor_hint():
		if AVC.has_bus(audio_bus):
			_on_avc_bus_volume_changed(audio_bus, AVC.get_bus_volume(audio_bus))

func _UpdateLabel() -> void:
	if _lbl_bus_name == null: return
	_lbl_bus_name.text = label_text
	_lbl_bus_name.custom_minimum_size = Vector2i(min_label_size, 0)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_avc_bus_volume_changed(bus : StringName, volume : float) -> void:
	if bus == audio_bus and not Engine.is_editor_hint():
		var active : bool = abs(volume) > 0.001
		if _slider_volume != null:
			_slider_volume.value = volume * _slider_volume.max_value
			_slider_volume.editable = active
		if _check_bus_active != null:
			_check_bus_active.set_pressed_no_signal(active)

func _on_check_bus_active_toggled(toggled_on: bool) -> void:
	if _check_bus_active == null: return
	if not toggled_on:
		AVC.set_bus_volume(audio_bus, 0.0)
	else:
		AVC.reset_bus_volume(audio_bus)

func _on_slider_volume_value_changed(value: float) -> void:
	AVC.set_bus_volume(audio_bus, value, true)
