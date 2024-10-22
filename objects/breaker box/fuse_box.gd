extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ANGLE_HANDLE_UP : float = deg_to_rad(-31)
const ANGLE_HANDLE_DOWN : float = deg_to_rad(31)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _breakerbox_handle: Node3D = $Breakerbox/Breakerbox_Handle


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Game.player_inventory_item_added.connect(_on_player_inventory_changed.bind(true))
	Game.player_inventory_item_removed.connect(_on_player_inventory_changed.bind(false))

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func blow_fuse() -> void:
	if _breakerbox_handle == null: return
	if not Game.player_has_item(Game.INV_OBJECT_POWEROUT):
		Game.add_player_item(Game.INV_OBJECT_POWEROUT)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_inventory_changed(item_name : StringName, item_added : bool) -> void:
	if item_name != Game.INV_OBJECT_POWEROUT or _breakerbox_handle == null: return
	_breakerbox_handle.rotation.x = ANGLE_HANDLE_DOWN if item_added else ANGLE_HANDLE_UP

func _on_interactable_interacted(payload: Dictionary) -> void:
	if _breakerbox_handle == null: return
	if Game.player_has_item(Game.INV_OBJECT_POWEROUT):
		Game.remove_player_item(Game.INV_OBJECT_POWEROUT)
	else:
		Game.add_player_item(Game.INV_OBJECT_POWEROUT)
