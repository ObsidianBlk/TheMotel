@tool
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
@export var enabled : bool = false : 					set = set_enable
@export_range(0.0, 16.0) var min_energy : float = 1.0:	set = set_min_energy
@export_range(0.0, 16.0) var max_energy : float = 1.0:	set = set_max_energy
@export var flicker_noise : FastNoiseLite = null:		set = set_flicker_noise

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _light_bar: CSGCylinder3D = $LightBar
@onready var _flicker: Flicker = $Flicker


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_enable(e : bool) -> void:
	if e != enabled:
		enabled = e
		_UpdateFlicker()

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

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Game.player_inventory_item_added.connect(_on_player_inventory_changed.bind(true))
	Game.player_inventory_item_removed.connect(_on_player_inventory_changed.bind(false))
	
	_flicker.material = _light_bar.material
	_UpdateFlickerNoise()
	_UpdateFlicker()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _Powerout() -> bool:
	return Game.player_has_item(Game.INV_OBJECT_POWEROUT)

func _UpdateFlicker() -> void:
	if _flicker == null: return
	_flicker.enabled = enabled and not _Powerout()
	_flicker.min_energy = min_energy
	_flicker.max_energy = max_energy

func _UpdateFlickerNoise() -> void:
	if _flicker == null: return
	_flicker.flicker_noise = flicker_noise

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_inventory_changed(item_name : StringName, item_added : bool) -> void:
	_UpdateFlicker()
