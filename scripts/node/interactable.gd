extends Area3D
class_name Interactable

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal interacted(payload : Dictionary)
signal interacted_long(payload : Dictionary)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const LONG_PRESS_DELAY = 0.25

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var enabled : bool = true:					set=set_enabled
@export var long_press_duration : float = 0.0:		set=set_long_press_duration
@export_multiline var message : String = "":		set=set_message

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _coll_layer = -1
var _showing = false

var _long_press_enabled : bool = false
var _long_press_payload : Dictionary = {}
var _long_press_delay : float = 0.0

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

func set_long_press_duration(d : float) -> void:
	if d >= 0.0:
		long_press_duration = d

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

func _process(delta: float) -> void:
	if not _long_press_enabled or long_press_duration <= 0.0: return
	var total_delay = LONG_PRESS_DELAY + long_press_duration
	_long_press_delay += delta
	if _long_press_delay >= total_delay:
		_long_press_enabled = false
		interacted_long.emit(_long_press_payload)
		_long_press_payload = {}
	elif _long_press_delay >= LONG_PRESS_DELAY:
		InteractMessage.Set_Progress((_long_press_delay - LONG_PRESS_DELAY) / long_press_duration)

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

func interact_long(enable : bool, payload : Dictionary = {}) -> void:
	if long_press_duration <= 0.0: return
	if _long_press_enabled == enable: return
	_long_press_enabled = enable
	if enabled:
		_long_press_delay = 0.0
		_long_press_payload = payload
	else:
		_long_press_payload = {}
		InteractMessage.Set_Message(message)

func update_message() -> void:
	if _showing and enabled and not message.is_empty():
		InteractMessage.Set_Message(message)
	else:
		_showing = false
		InteractMessage.Hide_Message()

func show_message(show_msg : bool = true) -> void:
	if not message.is_empty():
		if show_msg and enabled:
			_showing = true
			InteractMessage.Set_Message(message)
		else:
			_showing = false
			InteractMessage.Hide_Message()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
