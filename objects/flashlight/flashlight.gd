extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const MATERIAL_ON : Material = preload("res://objects/flashlight/light_on.material")
const MATERIAL_OFF : Material = preload("res://objects/flashlight/light_off.material")

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var enabled : bool = false:		set = set_enabled

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _light: SpotLight3D = $SpotLight3D
@onready var _mesh: MeshInstance3D = $Flashlight/Cylinder_002
@onready var _audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_enabled(e : bool) -> void:
	if e != enabled:
		enabled = e
		_UpdateFlashlightState()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateFlashlightState() -> void:
	if _light == null or _mesh == null: return
	if enabled:
		_light.visible = true
		_mesh.set_surface_override_material(0, MATERIAL_ON)
		if _audio != null and not _audio.playing:
			_audio.play()
	else:
		_light.visible = false
		_mesh.set_surface_override_material(0, MATERIAL_OFF)
		if _audio != null and not _audio.playing:
			_audio.play()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
