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
@export_multiline var message : String = "":		set=set_message

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _coll_layer = -1
var _showing = false

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

func set_message(m : String) -> void:
	message = m
	if _showing:
		InteractMessage.Set_Message(message)

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
			_showing = true
			InteractMessage.Set_Message(message)
		else:
			_showing = false
			InteractMessage.Hide_Message()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
