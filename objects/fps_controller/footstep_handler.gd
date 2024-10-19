extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const STREAMSET_ASPHALT : AudioStreamRandomizer = preload("res://objects/fps_controller/streamset_footsteps_asphalt.tres")
const STREAMSET_CARPET : AudioStreamRandomizer = preload("res://objects/fps_controller/streamset_footsteps_carpet.tres")
const STREAMSET_WOOD : AudioStreamRandomizer = preload("res://objects/fps_controller/streamset_footsteps_wood.tres")


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var enabled : bool = false:											set = set_enabled
@export var step_delay : float = 0.2:										set = set_step_delay
@export var audio_set : Game.FootstepType = Game.FootstepType.Asphalt:		set = set_audio_set
@export var audio_player : AudioStreamPlayer3D = null

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _delay : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_enabled(e : bool) -> void:
	if e != enabled:
		enabled = e
		if enabled:
			_delay = step_delay
		set_process(enabled)

func set_step_delay(d : float) -> void:
	if d > 0.0:
		step_delay = d

func set_audio_set(s : Game.FootstepType) -> void:
	audio_set = s
	_UpdateAudioStreamSet()

func set_audio_player(p : AudioStreamPlayer3D) -> void:
	audio_player = p
	_UpdateAudioStreamSet()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Game.register_action_handler(Game.ACTION_FOOTSTEPS, _action_footsteps)
	_UpdateAudioStreamSet()
	set_process(enabled)

func _process(delta: float) -> void:
	if audio_player == null: return
	if _delay <= 0.0:
		if not audio_player.playing:
			audio_player.play()
			_delay = step_delay
	else:
		_delay -= delta

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateAudioStreamSet() -> void:
	if audio_player == null: return
	match audio_set:
		Game.FootstepType.Asphalt:
			audio_player.stream = STREAMSET_ASPHALT
		Game.FootstepType.Carpet:
			audio_player.stream = STREAMSET_CARPET
		Game.FootstepType.Wood:
			audio_player.stream = STREAMSET_WOOD

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _action_footsteps(type : Game.FootstepType) -> void:
	audio_set = type
