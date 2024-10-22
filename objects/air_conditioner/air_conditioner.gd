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

const FULL_VOLUME_TIME : float = 2.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var state : State = State.FUNCTIONAL:		set=set_state
@export var enabled : bool = false:					set=set_enabled

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _volume : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _green_light: MeshInstance3D = $"AirConditioner/AirConditionerGreenLight/Air ConditionerGreenLight"
@onready var _red_light: MeshInstance3D = $AirConditioner/AirConditionerRedLight2/AirConditionerRedLight
@onready var _int_repair: Interactable = %Int_Repair
@onready var _asp_beep: AudioStreamPlayer3D = $ASP_Beep
@onready var _asp_white_noise: AudioStreamPlayer3D = $ASP_WhiteNoise

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
func _process(delta: float) -> void:
	if enabled and state == State.FUNCTIONAL and not _Powerout():
		if not is_equal_approx(_volume, FULL_VOLUME_TIME):
			if not _asp_white_noise.playing:
				_asp_white_noise.play()
			_volume = clampf(_volume + delta, 0.0, FULL_VOLUME_TIME)
			_asp_white_noise.volume_db = linear_to_db(_volume / FULL_VOLUME_TIME)
	elif not is_equal_approx(_volume, 0.0):
		_volume = clampf(_volume - delta, 0.0, FULL_VOLUME_TIME)
		_asp_white_noise.volume_db = linear_to_db(_volume / FULL_VOLUME_TIME)
		if is_equal_approx(_volume, 0.0):
			_asp_white_noise.stop()

# ------------------------------------------------------------------------------
# Private methods
# ------------------------------------------------------------------------------
func _Powerout() -> bool:
	return Game.player_has_item(Game.INV_OBJECT_POWEROUT)

func _UpdateControlLights() -> void:
	if enabled and not _Powerout():
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
	if not _asp_beep.playing:
		_asp_beep.play()


func _on_int_repair_interacted(payload: Dictionary) -> void:
	state = State.FUNCTIONAL
