@tool
extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ANIM_FLASHLIGHT_OFF : StringName = &"flashlight_off"
const ANIM_FLASHLIGHT_ON : StringName = &"flashlight_on"
const ANIM_FLASHLIGHT_AWAY : StringName = &"flashlight_away"
const ANIM_FLASHLIGHT_OUT : StringName = &"flashlight_out"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var available : bool = false:	set = set_available
@export var enabled : bool = false:		set = set_enabled

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _can_interact : bool = true

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _anims: AnimationPlayer = $"../Anims"
@onready var _flashlight: Node3D = $"../Camera/FlashLight"


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_available(a : bool) -> void:
	if available != a:
		if not a:
			enabled = false
		available = a
		if _flashlight != null:
			_flashlight.visible = available

func set_enabled(e : bool) -> void:
	if available and enabled != e:
		enabled = e
		_UpdateEnableState()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		_flashlight.visible = available
		_can_interact = false
		_anims.play(ANIM_FLASHLIGHT_OFF)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateEnableState() -> void:
	if Engine.is_editor_hint(): return
	_can_interact = false
	var anim : StringName = ANIM_FLASHLIGHT_OUT if enabled else ANIM_FLASHLIGHT_AWAY
	print("Playing anim: ", anim)
	_anims.play(anim)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_anim_finished(anim_name : StringName) -> void:
	print("Animation Complete")
	_can_interact = true
