extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal returned_home()
signal transported()

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

const ANIM_S4_POSSESSION : StringName = &"SET4_Clown_Possession"

const ACTION_NOTHING : StringName = &"Nothing"
const ACTION_SIT_UP : StringName = &"SitUp"
const ACTION_BELL_TINKLE : StringName = &"BellTinkle"
const ACTION_FALL_OVER : StringName = &"FallOver"

const STATE_SWAP_PROBABILITY : Vector2 = Vector2(0.1, 0.2)

const GROUP_CLOWN_REST : StringName = &"ClownRest"

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

var _on_screen : bool = false
var _player_detected : bool = false
var _first_detect : bool = false

var _is_home : bool = false
var _can_jump : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var _anim: AnimationPlayer = $CreepyClownDoll/AnimationPlayer
@onready var _jump_check_timer: Timer = %JumpCheckTimer
@onready var _interactable: Interactable = $Interactable


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_is_static(s : bool) -> void:
	is_static = s

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Game.player_inventory_item_added.connect(_on_player_inventory_changed.bind(true))
	Game.player_inventory_item_removed.connect(_on_player_inventory_changed.bind(false))
	if is_static: # This is a quick hack
		_Play(ANIM_S4_POSSESSION)
	else:
		_Play(ANIM_S1_SITTING)
	_wrc = WeightedRandomCollection.new()
	_wrc.add_entry(ACTION_NOTHING, 20)
	_wrc.add_entry(ACTION_SIT_UP, 10)
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

func _ProcessForEntered() -> void:
	if is_static or not _player_detected or not visible: return
	if not _first_detect:
		_first_detect = true
		_on_clown_home_detected(null) # This is a hack!!
	elif _state == State.Set1:
		var prob : float = randf()
		if prob >= STATE_SWAP_PROBABILITY.x and prob <= STATE_SWAP_PROBABILITY.y:
			_Play(ANIM_S1_TO_S2)
			_state = State.Set2

func _JumpToClownRest() -> void:
	var crl : Array[Node] = get_tree().get_nodes_in_group(GROUP_CLOWN_REST)
	if crl.size() > 0:
		var idx : int = randi() % crl.size()
		var cr : Node3D = crl[idx]
		global_position = cr.global_position
		global_basis = Basis(cr.global_basis)
		_is_home = false
		
		var anim_name : StringName = ANIM_S1_SITTING if _state == State.Set1 else ANIM_S2_SITTING
		_Play(anim_name)
		transported.emit()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interact(payload : Dictionary) -> void:
	if not visible: return
	Game.add_player_item(Game.INV_OBJECT_CLOWN)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_screen_entered() -> void:
	_on_screen = true
	_ProcessForEntered()

func _on_screen_exited() -> void:
	_on_screen = false
	if _wrc != null and not is_static and _player_detected and visible:
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


func _on_player_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group(Game.GROUP_PLAYER):
		_player_detected = true
		_ProcessForEntered()

func _on_player_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group(Game.GROUP_PLAYER):
		_player_detected = false

func _on_clown_home_detected(_hitbox: Hitbox) -> void:
	returned_home.emit()
	if not _first_detect: return
	print("Clown is HOME!")
	_is_home = true
	_can_jump = false
	_jump_check_timer.start()

func _on_jump_check_timer_timeout() -> void:
	print("Clown checking jump...")
	if not _can_jump:
		print("Clown can't jump yet")
		_can_jump = true
	elif _on_screen or _player_detected:
		print("Clown things player can see")
	else:
		if randf() < 0.1:
			print("Clown AWAY!")
			_can_jump = false
			_jump_check_timer.stop()
			_JumpToClownRest()
		else:
			print("Clown fine here")

func _on_player_inventory_changed(item_name : StringName, item_added : bool) -> void:
	if item_name == Game.INV_OBJECT_CLOWN:
		if item_added:
			_jump_check_timer.stop()
			_interactable.show_message(false)
			_interactable.enabled = false
			visible = false
			global_position.y += 1000.0
			transported.emit()
		else:
			_interactable.enabled = true
			visible = true

func _on_animation_finished(anim_name: StringName) -> void:
	if is_static and anim_name == ANIM_S4_POSSESSION:
		_Play(ANIM_S4_POSSESSION)
