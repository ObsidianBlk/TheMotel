extends Area3D
class_name Interactable

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal interacted(payload : Dictionary)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var enabled : bool = true:					set=set_enabled
@export_multiline var message : String = ""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _coll_layer = -1

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_enabled(e : bool) -> void:
	if e != enabled:
		enabled = e
		_UpdateEnabled()
		

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateEnabled()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateEnabled() -> void:
	if _coll_layer < 0:
		_coll_layer = collision_layer
	collision_layer = _coll_layer if enabled else 0

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interact(payload : Dictionary = {}) -> void:
	interacted.emit(payload)

func show_message(show : bool = true) -> void:
	if not message.is_empty():
		if show:
			InteractMessage.Set_Message(message)
		else:
			InteractMessage.Hide_Message()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
