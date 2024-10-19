extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal relayed(action : StringName, payload : Dictionary)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const GROUP_PLAYER : StringName = &"Player"
enum FootstepType {Asphalt=0, Carpet=1, Wood=2}

const ACTION_FOOTSTEPS : StringName = &"footsteps"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _registered_actions : Dictionary = {}

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

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
