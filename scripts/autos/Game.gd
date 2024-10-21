@tool
extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal player_inventory_item_added(item_name : StringName)
signal player_inventory_item_removed(item_name : StringName)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const GROUP_PLAYER : StringName = &"Player"
const GROUP_CLOWN_DOLL : StringName = &"ClownDoll"

enum FootstepType {Asphalt=0, Carpet=1, Wood=2}

const INV_OBJECT_FLASHLIGHT : StringName = &"flashlight"
const INV_OBJECT_KEY : StringName = &"room key"
const INV_OBJECT_BULB : StringName = &"bulb"

const ACTION_FOOTSTEPS : StringName = &"footsteps"
const ACTION_LIGHTS_CHANGED : StringName = &"lights_changed"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _registered_actions : Dictionary = {}
var _player_inventory : Dictionary = {}

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func register_action_handler(action : StringName, handler : Callable) -> int:
	if action.strip_edges().is_empty() or handler == null: return ERR_INVALID_PARAMETER
	if not action in _registered_actions:
		_registered_actions[action] = []
	if _registered_actions[action].find(handler) >= 0:
		return ERR_ALREADY_EXISTS
	_registered_actions[action].append(handler)
	return OK

func unregister_action_handler(action : StringName, handler : Callable) -> void:
	if not action in _registered_actions: return
	
	var idx : int = _registered_actions[action].find(handler)
	if idx < 0: return
	
	_registered_actions[action].remove_at(idx)
	if _registered_actions[action].size() <= 0:
		_registered_actions.erase(action)

func send_action(action : StringName, args : Array) -> void:
	if action in _registered_actions:
		for fn : Callable in _registered_actions[action]:
			fn.callv(args)

func add_player_item(item_name : StringName) -> int:
	if item_name in _player_inventory: return ERR_ALREADY_EXISTS
	_player_inventory[item_name] = true
	player_inventory_item_added.emit(item_name)
	return OK

func remove_player_item(item_name : StringName) -> int:
	if not item_name in _player_inventory: return ERR_CANT_ACQUIRE_RESOURCE
	_player_inventory.erase(item_name)
	player_inventory_item_removed.emit(item_name)
	return OK

func player_has_item(item_name : StringName) -> bool:
	return item_name in _player_inventory

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
