extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ANIM_HAND_DOWN : StringName = &"hand_down"
const ANIM_HAND_UP : StringName = &"hand_up"
const ANIM_HAND_LOWER : StringName = &"hand_lower"
const ANIM_HAND_RAISE : StringName = &"hand_raise"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _in_hand : StringName = &""

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _clown: Node3D = %Clown
@onready var _anims: AnimationPlayer = $"../Anims"


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Game.player_inventory_item_added.connect(_on_player_inventory_changed.bind(true))
	Game.player_inventory_item_removed.connect(_on_player_inventory_changed.bind(false))
	_anims.play(ANIM_HAND_DOWN)

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
	if item_added:
		if item_name == Game.INV_OBJECT_CLOWN:
			_clown.visible = true
			_anims.play(ANIM_HAND_RAISE)
	else:
		if item_name == Game.INV_OBJECT_CLOWN:
			_anims.play(ANIM_HAND_LOWER)
			await _anims.animation_finished
			_clown.visible = false
