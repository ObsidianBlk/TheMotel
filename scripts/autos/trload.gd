extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _queue : Dictionary = {}

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
func update_queue() -> void:
	for key : String in _queue.keys():
		var progress : Array = []
		var status : int = ResourceLoader.load_threaded_get_status(key, progress)
		match status:
			1: # In Progress
				_queue[key].call(null, progress[0], OK)
			3: # Load complete
				var res : Resource = ResourceLoader.load_threaded_get(key)
				if res != null:
					_queue[key].call(res, progress[0], OK)
				else:
					_queue[key].call(null, progress[0], ERR_CANT_ACQUIRE_RESOURCE)
				_queue.erase(key)
			_: # Load Failed
				_queue[key].call(null, 0.0, ERR_INVALID_DATA)
				_queue.erase(key)

func request_resource(resource_path : String, callback : Callable) -> int:
	if resource_path in _queue: return ERR_FILE_ALREADY_IN_USE
	if callback == null: return ERR_INVALID_PARAMETER
	_queue[resource_path] = callback
	ResourceLoader.load_threaded_request(resource_path)
	return OK

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
