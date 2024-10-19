extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var enabled : bool = false:						set = set_enable
@export_range(0.0, 16.0) var min_energy : float = 1.0:	set = set_min_energy
@export_range(0.0, 16.0) var max_energy : float = 1.0:	set = set_max_energy
@export var flicker_noise : FastNoiseLite = null:		set = set_flicker_noise
@export_multiline var enabled_message : String = "":	set = set_enabled_message
@export_multiline var disabled_message : String = "":	set = set_disabled_message



# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _flicker: Flicker = $Flicker
@onready var _interactable: Interactable = $Interactable
@onready var _audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_enable(e : bool) -> void:
	if e != enabled:
		enabled = e
		_UpdateFlicker()
		_PlayClick()

func set_min_energy(e : float) -> void:
	if e >= 0.0 and e <= 16.0:
		min_energy = min(max_energy, e)
		_UpdateFlicker()

func set_max_energy(e : float) -> void:
	if e >= 0.0 and e <= 16.0:
		max_energy = max(min_energy, e)
		_UpdateFlicker()

func set_flicker_noise(n : FastNoiseLite) -> void:
	if n != flicker_noise:
		flicker_noise = n
		_UpdateFlickerNoise()

func set_enabled_message(m : String) -> void:
	enabled_message = m
	_UpdateInteractMessage()

func set_disabled_message(m : String) -> void:
	disabled_message = m
	_UpdateInteractMessage()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateFlickerNoise()
	_UpdateFlicker()
	_UpdateInteractMessage()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateFlicker() -> void:
	if _flicker == null: return
	_flicker.enabled = enabled
	_flicker.min_energy = min_energy
	_flicker.max_energy = max_energy

func _UpdateFlickerNoise() -> void:
	if _flicker == null: return
	_flicker.flicker_noise = flicker_noise

func _UpdateInteractMessage() -> void:
	if _interactable == null: return
	var msg : String = enabled_message if enabled else disabled_message
	_interactable.message = msg

func _PlayClick() -> void:
	if _audio == null: return
	if not _audio.playing:
		_audio.play()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interact(payload : Dictionary = {}) -> void:
	enabled = not enabled

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
