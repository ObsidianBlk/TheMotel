extends Node3D
class_name AirConditioner


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal state_changed(state)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
enum State {FUNCTIONAL=0, BROKEN=1}

const MATERIAL_EMISSIVE_RED : Material = preload("res://assets/materials/emissive_red.material")
const MATERIAL_EMISSIVE_GREEN : Material = preload("res://assets/materials/emissive_green.material")


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state : State = State.FUNCTIONAL:		set=set_state
@export var enabled : bool = false:					set=set_enabled

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _green_light: MeshInstance3D = $"AirConditioner/AirConditionerGreenLight/Air ConditionerGreenLight"
@onready var _red_light: MeshInstance3D = $AirConditioner/AirConditionerRedLight2/AirConditionerRedLight
@onready var _int_repair: Interactable = %Int_Repair

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_state(s : State) -> void:
	if state != s:
		state = s
		_UpdateControlLights()
		state_changed.emit(state)

func set_enabled(e : bool) -> void:
	if enabled != e:
		enabled = e
		_UpdateControlLights()

# ------------------------------------------------------------------------------
# Override methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private methods
# ------------------------------------------------------------------------------
func _UpdateControlLights() -> void:
	if enabled:
		match state:
			State.FUNCTIONAL:
				if _int_repair != null:
					_int_repair.enabled = false
				if _green_light != null:
					_green_light.set_surface_override_material(0, MATERIAL_EMISSIVE_GREEN)
				if _red_light != null:
					_red_light.set_surface_override_material(0, null)
			State.BROKEN:
				if _green_light != null:
					_green_light.set_surface_override_material(0, null)
				if _red_light != null:
					_red_light.set_surface_override_material(0, MATERIAL_EMISSIVE_RED)
				if _int_repair != null:
					_int_repair.enabled = true
	else:
		if _int_repair != null:
			_int_repair.enabled = false
		if _green_light != null:
			_green_light.set_surface_override_material(0, null)
		if _red_light != null:
			_red_light.set_surface_override_material(0, null)

# ------------------------------------------------------------------------------
# Handler methods
# ------------------------------------------------------------------------------

func _on_int_power_interacted(payload: Dictionary) -> void:
	enabled = not enabled


func _on_int_repair_interacted(payload: Dictionary) -> void:
	state = State.FUNCTIONAL
