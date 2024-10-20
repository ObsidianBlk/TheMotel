extends Area3D
class_name Region

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal lights_changed(active : bool)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const AUDIO_BUS_AMBIENT : StringName = &"Ambient_Outdoor"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var footsteps : Game.FootstepType = Game.FootstepType.Asphalt
@export_range(0.0, 1.0, 0.01) var ambient_level : float = 1.0
@export var lights_on : bool = false:									set=set_lights_on

# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var _OwningRegion : StringName = &""
static var _AmbientTarget : float = 1.0


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_lights_on(e : bool) -> void:
	if e != lights_on:
		lights_on = e
		lights_changed.emit(lights_on)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if _OwningRegion != name : return
	_UpdateAmbientShift(delta)

# ------------------------------------------------------------------------------
# Static Private Methods
# ------------------------------------------------------------------------------
static func _UpdateAmbientShift(delta : float) -> void:
	var idx : int = AudioServer.get_bus_index(AUDIO_BUS_AMBIENT)
	if idx >= 0:
		var vol : float = db_to_linear(AudioServer.get_bus_volume_db(idx))
		if not is_equal_approx(vol, _AmbientTarget):
			vol = lerpf(vol, _AmbientTarget, delta)
			AudioServer.set_bus_volume_db(idx, linear_to_db(vol))


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_body_entered(body : Node3D) -> void:
	if body.is_in_group(Game.GROUP_PLAYER):
		Game.send_action(Game.ACTION_FOOTSTEPS, [footsteps])
		_OwningRegion = name
		_AmbientTarget = ambient_level
