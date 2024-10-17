extends Node


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal bus_volume_changed(bus : StringName, volume : float)

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const AUDIO_BUS_MASTER : StringName = &"Master"
const AUDIO_BUS_MUSIC : StringName = &"Music"
const AUDIO_BUS_SFX : StringName = &"SFX"

const SETTINGS_SECTION_AUDIO : String = "AUDIO"

const VOLUME_MULTIPLIER : float = 0.001

const DEFAULT_BUS_VOLUME_MASTER : float = 1000.0
const DEFAULT_BUS_VOLUME_MUSIC : float = 500.0
const DEFAULT_BUS_VOLUME_SFX : float = 800.0


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
#var _abus : Dictionary = {
	#AUDIO_BUS_MASTER: DEFAULT_BUS_VOLUME_MASTER,
	#AUDIO_BUS_MUSIC: DEFAULT_BUS_VOLUME_MUSIC,
	#AUDIO_BUS_SFX: DEFAULT_BUS_VOLUME_SFX
#}

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Settings.reset.connect(_on_settings_reset)
	Settings.loaded.connect(_on_settings_loaded)
	Settings.value_changed.connect(_on_settings_value_changed)
	_UpdateAudioFromSettings()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateAudioFromSettings() -> void:
	var volume : float = Settings.get_value(SETTINGS_SECTION_AUDIO, AUDIO_BUS_MASTER, DEFAULT_BUS_VOLUME_MASTER)
	_SetBusVolume(AUDIO_BUS_MASTER, volume)
	bus_volume_changed.emit(AUDIO_BUS_MASTER, volume * VOLUME_MULTIPLIER)
	
	volume = Settings.get_value(SETTINGS_SECTION_AUDIO, AUDIO_BUS_MUSIC, DEFAULT_BUS_VOLUME_MUSIC)
	_SetBusVolume(AUDIO_BUS_MUSIC, volume)
	bus_volume_changed.emit(AUDIO_BUS_MUSIC, volume * VOLUME_MULTIPLIER)
	
	volume = Settings.get_value(SETTINGS_SECTION_AUDIO, AUDIO_BUS_SFX, DEFAULT_BUS_VOLUME_SFX)
	_SetBusVolume(AUDIO_BUS_SFX, volume)
	bus_volume_changed.emit(AUDIO_BUS_SFX, volume * VOLUME_MULTIPLIER)


func _SetBusVolume(bus : StringName, volume : float) -> void:
	volume = clampf(volume, 0.0, 1000.0) * VOLUME_MULTIPLIER
	
	var bus_idx : int = AudioServer.get_bus_index(bus)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_bus_volume(bus : StringName, volume : float, large_val : bool = false) -> void:
	if large_val:
		volume = clampf(volume, 0.0, 1000.0)
	else:
		volume = clampf(volume, 0.0, 1.0) * 1000.0
	
	Settings.set_value(SETTINGS_SECTION_AUDIO, bus, volume)

func get_bus_volume(bus : StringName, large_val : bool = false) -> float:
	var volume : float = 0.0
	var bus_idx : int = AudioServer.get_bus_index(bus)
	if bus_idx >= 0:
		volume = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
		if large_val: return volume * 1000.0
	return volume

func has_bus(bus : StringName) -> bool:
	return AudioServer.get_bus_index(bus) >= 0

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_settings_reset() -> void:
	set_bus_volume(AUDIO_BUS_MASTER, DEFAULT_BUS_VOLUME_MASTER, true)
	set_bus_volume(AUDIO_BUS_MUSIC, DEFAULT_BUS_VOLUME_MUSIC, true)
	set_bus_volume(AUDIO_BUS_SFX, DEFAULT_BUS_VOLUME_SFX, true)

func _on_settings_loaded() -> void:
	_UpdateAudioFromSettings()

func _on_settings_value_changed(section : String, key : String, value : Variant) -> void:
	if section == SETTINGS_SECTION_AUDIO:
		if typeof(value) != TYPE_FLOAT: return
		if has_bus(key):
			_SetBusVolume(key, value)
			bus_volume_changed.emit(key, value * VOLUME_MULTIPLIER)
