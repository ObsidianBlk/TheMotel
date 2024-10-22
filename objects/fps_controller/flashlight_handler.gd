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
#@export var available : bool = false:	set = set_available
@export var enabled : bool = false:		set = set_enabled

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _available : bool = false
var _can_interact : bool = true

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _anims: AnimationPlayer = $"../Anims"
@onready var _flashlight: Node3D = $"../Camera/FlashLight"


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
#func set_available(a : bool) -> void:
	#if available != a:
		#if not a:
			#enabled = false
		#available = a
		#if _flashlight != null:
			#_flashlight.visible = available

func set_enabled(e : bool) -> void:
	if _available and enabled != e:
		enabled = e
		_UpdateEnableState()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		Game.player_inventory_item_added.connect(_on_player_inventory_item_changed.bind(true))
		Game.player_inventory_item_removed.connect(_on_player_inventory_item_changed.bind(false))
		_flashlight.visible = _available
		_can_interact = false
		_anims.play(ANIM_FLASHLIGHT_OFF)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateEnableState() -> void:
	if Engine.is_editor_hint(): return
	_can_interact = false
	var anim : StringName = ANIM_FLASHLIGHT_OUT if enabled else ANIM_FLASHLIGHT_AWAY
	_anims.play(anim)


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_anim_finished(anim_name : StringName) -> void:
	if [ANIM_FLASHLIGHT_OUT, ANIM_FLASHLIGHT_AWAY].find(anim_name) >= 0:
		_can_interact = true

func _on_player_inventory_item_changed(item_name : StringName, item_added : bool) -> void:
	if item_name == Game.INV_OBJECT_FLASHLIGHT:
		if not item_added:
			enabled = false
		else:
			_anims.play(ANIM_FLASHLIGHT_OFF)
		_available = item_added
		if _flashlight != null:
			_flashlight.visible = _available
