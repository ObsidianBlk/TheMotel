@tool
extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ENERGY_AMOUNT_THRESHOLD : float = 0.01
const LIGHT_SPEED : float = 10.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var enabled : bool = false
@export_range(0.0, 16.0) var min_energy : float = 1.0:	set = set_min_energy
@export_range(0.0, 16.0) var max_energy : float = 1.0:	set = set_max_energy
@export var flicker_noise : FastNoiseLite = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _energy_amount : float = 0.0
var _noise_pos : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _light_bar: CSGCylinder3D = $LightBar
@onready var _audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_min_energy(e : float) -> void:
	if e >= 0.0 and e <= 16.0:
		min_energy = min(max_energy, e)
		_UpdateEnergyAmount()

func set_max_energy(e : float) -> void:
	if e >= 0.0 and e <= 16.0:
		max_energy = max(min_energy, e)
		_UpdateEnergyAmount()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


func _process(delta: float) -> void:
	var charge : float = 1.0
	var flicker_mult : float = _HandleFlicker(delta)
	_UpdateEnergy((min_energy + (_energy_amount * flicker_mult)) * charge)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateEnergyAmount() -> void:
	_energy_amount = max_energy - min_energy
	if _energy_amount < ENERGY_AMOUNT_THRESHOLD:
		_energy_amount = 0.0
		_UpdateEnergy(max_energy)
	if flicker_noise == null:
		_UpdateEnergy(min_energy)

func _UpdateEnergy(amount : float) -> void:
	if not enabled :
		amount = 0.0
	
	if _audio != null:
		_audio.volume_db = linear_to_db(amount)
	#if _light != null:
		#_light.light_energy = amount
		#_light.visible = amount > 0.0
	if _light_bar != null:
		_light_bar.material.emission_energy_multiplier = amount
		_light_bar.material.emission_enabled = amount > 0.0


func _HandleFlicker(delta : float) -> float:
	if flicker_noise == null or _energy_amount <= 0.0 : return 0.0
	#if not flicker_in_editor:
		#if Engine.is_editor_hint(): return 0.0
	
	_noise_pos = fmod(_noise_pos + (delta * LIGHT_SPEED), 128.0)
	return wrapf(flicker_noise.get_noise_1d(_noise_pos) + 1.0, 0.0, 1.0)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
