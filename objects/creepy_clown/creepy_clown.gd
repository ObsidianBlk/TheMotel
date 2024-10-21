extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const AUDIO_STREAM_TINKLE : AudioStreamRandomizer = preload("res://objects/creepy_clown/tinkle_stream.tres")
const AUDIO_STREAM_FALLOVER : AudioStreamRandomizer = preload("res://objects/creepy_clown/fallover_stream.tres")

const ANIM_S1_SITTING : StringName = &"SET1_Clown_Sitting"
const ANIM_S1_SITTING_BELL : StringName = &"SET1_Clown_Sitting_BellTinkle"
const ANIM_S1_FALL_OVER : StringName = &"SET1_Clown_FallOver"

const ANIM_S1_TO_S2 : StringName = &"SET1to2_OpenEye"

const ANIM_S2_SITTING : StringName = &"SET2_Clown_Sitting"
const ANIM_S2_SITTING_BELL : StringName = &"SET2_Clown_Sitting_BellTinkle"
const ANIM_S2_FALL_OVER : StringName = &"SET2_Clown_FallOver"

const ACTION_NOTHING : StringName = &"Nothing"
const ACTION_SIT_UP : StringName = &"SitUp"
const ACTION_BELL_TINKLE : StringName = &"BellTinkle"
const ACTION_FALL_OVER : StringName = &"FallOver"

const STATE_SWAP_PROBABILITY : Vector2 = Vector2(0.1, 0.2)

enum State {Set1=0, Set2=1}

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var is_static : bool = false

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _state : State = State.Set1
var _fell : bool = false
var _wrc : WeightedRandomCollection = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var _anim: AnimationPlayer = $CreepyClownDoll/AnimationPlayer


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_Play(ANIM_S1_SITTING)
	_wrc = WeightedRandomCollection.new()
	_wrc.add_entry(ACTION_NOTHING, 5)
	_wrc.add_entry(ACTION_SIT_UP, 4)
	_wrc.add_entry(ACTION_BELL_TINKLE, 3)
	_wrc.add_entry(ACTION_FALL_OVER, 1)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetAudioStreamFromAnimName(anim_name : StringName) -> AudioStream:
	if anim_name.ends_with("BellTinkle"):
		return AUDIO_STREAM_TINKLE
	if anim_name.ends_with("FallOver"):
		return AUDIO_STREAM_FALLOVER
	return null

func _Play(anim_name : StringName) -> void:
	if _anim != null:
		var stream : AudioStream = _GetAudioStreamFromAnimName(anim_name)
		_anim.play(anim_name)
		if _audio != null and stream != null:
			_audio.stream = stream
			_audio.play()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_screen_entered() -> void:
	if is_static: return
	if _state == State.Set1:
		var prob : float = randf()
		if prob >= STATE_SWAP_PROBABILITY.x and prob <= STATE_SWAP_PROBABILITY.y:
			_Play(ANIM_S1_TO_S2)
			_state = State.Set2

func _on_screen_exited() -> void:
	if _wrc != null and not is_static:
		var action : StringName = _wrc.get_random()
		var anim_name : StringName = &""
		if not _fell:
			match action:
				ACTION_BELL_TINKLE:
					anim_name = ANIM_S1_SITTING_BELL if _state == State.Set1 else ANIM_S2_SITTING_BELL
				ACTION_FALL_OVER:
					anim_name = ANIM_S1_FALL_OVER if _state == State.Set1 else ANIM_S2_FALL_OVER
		elif action == ACTION_SIT_UP:
			_fell = false
			anim_name = ANIM_S1_SITTING if _state == State.Set1 else ANIM_S2_SITTING
		
		print("Screen Exit Action: ", action)
		if not anim_name.is_empty():
			_Play(anim_name)
