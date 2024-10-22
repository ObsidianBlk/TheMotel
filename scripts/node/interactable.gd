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
		update_message()

func set_message(m : String) -> void:
	message = m
	update_message()
	#if _showing:
		#if message.is_empty():
			#InteractMessage.Hide_Message()
		#else:
			#InteractMessage.Set_Message(message)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_coll_layer = collision_layer
	_UpdateEnabled()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateEnabled() -> void:
	for child : Node in get_children():
		if child is CollisionShape3D:
			child.disabled = not enabled
		elif child is CollisionPolygon3D:
			child.disabled = not enabled
	#if _coll_layer < 0:
		#_coll_layer = collision_layer
	#collision_layer = _coll_layer if enabled else 0

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interact(payload : Dictionary = {}) -> void:
	interacted.emit(payload)

func update_message() -> void:
	if _showing and enabled and not message.is_empty():
		InteractMessage.Set_Message(message)
	else:
		_showing = false
		InteractMessage.Hide_Message()

func show_message(show : bool = true) -> void:
	if not message.is_empty():
		if show and enabled:
			_showing = true
			InteractMessage.Set_Message(message)
		else:
			_showing = false
			InteractMessage.Hide_Message()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
