@tool
extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var has_key : bool = true:						set = set_has_key
@export_multiline var occupied_message : String = ""
@export_multiline var missing_message : String = ""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _room_key: Node3D = $RoomKey
@onready var _interactable: Interactable = $Interactable


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_has_key(h : bool) -> void:
	if h != has_key:
		has_key = h
		_UpdateKey()

func set_occupied_message(msg : String) -> void:
	occupied_message = msg
	_UpdateKey()

func set_missing_message(msg : String) -> void:
	missing_message = msg
	_UpdateKey()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Game.player_inventory_item_added.connect(_on_player_inventory_item_Changed)
	Game.player_inventory_item_removed.connect(_on_player_inventory_item_Changed)
	_UpdateKey()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateKey() -> void:
	if _room_key == null: return
	_room_key.visible = has_key
	if _interactable != null:
		var player_has_key : bool = Game.player_has_item(Game.INV_OBJECT_KEY)
		_interactable.enabled = has_key != player_has_key
		if has_key:
			_interactable.message = occupied_message
		else:
			_interactable.message = missing_message

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interact(payload : Dictionary = {}) -> void:
		if has_key and not Game.player_has_item(Game.INV_OBJECT_KEY):
			Game.add_player_item(Game.INV_OBJECT_KEY)
			has_key = false
		elif not has_key and Game.player_has_item(Game.INV_OBJECT_KEY):
			Game.remove_player_item(Game.INV_OBJECT_KEY)
			has_key = true

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_inventory_item_Changed(item_name : StringName) -> void:
	_UpdateKey()
