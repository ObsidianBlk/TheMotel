extends Node3D
class_name Lamp

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var functional : bool = true:						set = set_functional
@export var enabled : bool = false:							set = set_enable
@export var region : Region = null
@export_range(0.0, 16.0) var min_energy : float = 1.0:		set = set_min_energy
@export_range(0.0, 16.0) var max_energy : float = 1.0:		set = set_max_energy
@export var flicker_noise : FastNoiseLite = null:			set = set_flicker_noise
@export_multiline var enabled_message : String = "":		set = set_enabled_message
@export_multiline var disabled_message : String = "":		set = set_disabled_message
@export_multiline var broken_bulb_message : String = "":	set = set_broken_bulb_message
@export_multiline var broken_no_bulb_message : String = "":	set = set_broken_no_bulb_message



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
func set_functional(f : bool) -> void:
	if functional != f:
		if not f:
			enabled = false
		functional = f
		_UpdateInteractMessage()


func set_enable(e : bool) -> void:
	if functional and e != enabled:
		enabled = e
		if region != null:
			region.lights_on = enabled
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

func set_broken_bulb_message(m : String) -> void:
	broken_bulb_message = m
	_UpdateInteractMessage()

func set_broken_no_bulb_message(m : String) -> void:
	broken_no_bulb_message = m
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
	var msg : String = ""
	if functional:
		msg = enabled_message if enabled else disabled_message
	else:
		var player_has : bool = Game.player_has_item(Game.INV_OBJECT_BULB)
		msg = broken_bulb_message if player_has else broken_no_bulb_message
	_interactable.message = msg

func _PlayClick() -> void:
	if _audio == null: return
	if not _audio.playing:
		_audio.play()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interact(payload : Dictionary = {}) -> void:
	if functional:
		enabled = not enabled
	elif Game.player_has_item(Game.INV_OBJECT_BULB):
		Game.remove_player_item(Game.INV_OBJECT_BULB)
		functional = true

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
