extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const LIGHTS_OFF_MATERIAL : Material = preload("res://assets/materials/light_off.material")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _streetlight: MeshInstance3D = $StreetLight/Streetlight
@onready var _light1: SpotLight3D = $StreetLight/SpotLight3D
@onready var _light2: OmniLight3D = $StreetLight/SpotLight3D/OmniLight3D



# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Game.player_inventory_item_added.connect(_on_player_inventory_changed.bind(true))
	Game.player_inventory_item_removed.connect(_on_player_inventory_changed.bind(false))

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_inventory_changed(item_name : StringName, item_added : bool) -> void:
	if item_name == Game.INV_OBJECT_POWEROUT:
		if item_added:
			_light1.visible = false
			_light2.visible = false
			_streetlight.set_surface_override_material(1, LIGHTS_OFF_MATERIAL)
		else:
			_light1.visible = true
			_light2.visible = false
			_streetlight.set_surface_override_material(1, null)
