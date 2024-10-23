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
const INV_OBJECT_CLOWN : StringName = &"clown"
const INV_OBJECT_POWEROUT : StringName = &"power_out" # This is a late hour hack!!

const ACTION_FOOTSTEPS : StringName = &"footsteps"
const ACTION_LIGHTS_CHANGED : StringName = &"lights_changed"
const ACTION_SHOW_SCREEN : StringName = &"show_screen"

const BDD_SCENE : StringName = &"scene"
const BDD_INSTANCE : StringName = &"instance"

const BACKDROP_MAIN : StringName = &"backdrop_main"
const BACKDROP_GHOST : StringName = &"backdrop_ghost"
const BACKDROP_CLOWN : StringName = &"backdrop_clown"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _registered_actions : Dictionary = {}
var _player_inventory : Dictionary = {}

var _backdrops : Dictionary = {
	BACKDROP_MAIN:{
		BDD_SCENE: preload("res://scenes/backdrops/main_backdrop/main_backdrop.tscn"),
		BDD_INSTANCE: null
	},
	BACKDROP_GHOST:{
		BDD_SCENE: preload("res://scenes/backdrops/ghost_backdrop/ghost_backdrop.tscn"),
		BDD_INSTANCE: null
	},
	BACKDROP_CLOWN:{
		BDD_SCENE: preload("res://scenes/backdrops/clown_backdrop/clown_backdrop.tscn"),
		BDD_INSTANCE: null
	}
}

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

func clear_player_items() -> void:
	_player_inventory.clear()

func player_has_item(item_name : StringName) -> bool:
	return item_name in _player_inventory

func has_backdrop_scene(backdrop_name : String) -> bool:
	return backdrop_name in _backdrops

func get_backdrop_node(backdrop_name : String) -> Node3D:
	if backdrop_name in _backdrops:
		if _backdrops[backdrop_name][BDD_INSTANCE] != null:
			return _backdrops[backdrop_name][BDD_INSTANCE]
		if _backdrops[backdrop_name][BDD_SCENE] is PackedScene:
			var inst : Node = _backdrops[backdrop_name][BDD_SCENE].instantiate()
			if inst is Node3D:
				_backdrops[backdrop_name][BDD_INSTANCE] = inst
				return inst
	return null


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
