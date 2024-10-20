@tool
extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const FLOAT_THRESHOLD : float = 0.001
const DOOR_MAX_ANGLE : float = deg_to_rad(135.0)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_range(-DOOR_MAX_ANGLE, DOOR_MAX_ANGLE, 0.01) var open_angle : float = 0.0
@export var duration : float = 1.0:															set=set_duration
@export_range(0, 12, 1) var door_number : int = 0:											set=set_door_number
@export_multiline var closed_message : String = "":											set=set_closed_message
@export_multiline var opened_message : String = "":											set=set_opened_message

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _door_open : bool = false
var _tween : Tween = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _interactable: Interactable = $MotelDoor/Interactable
@onready var _motel_door: Node3D = $MotelDoor
@onready var _collision: CollisionShape3D = $MotelDoor/Door_002LT/StaticBody3D/CollisionShape3D
@onready var _text_object : Array[MeshInstance3D] = [
	null,
	null,
	$MotelDoor/Text_002,
	$MotelDoor/Text_003,
	$MotelDoor/Text_004,
	$MotelDoor/Text_005,
	$MotelDoor/Text_006,
	$MotelDoor/Text_007,
	$MotelDoor/Text_008,
	$MotelDoor/Text_009,
	$MotelDoor/Text_010,
	$MotelDoor/Text_011,
	$MotelDoor/Text_012
]

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_door_number(n : int) -> void:
	if n >= 0 and n <= 12 and n != door_number:
		door_number = n
		_UpdateDoorNumber()

func set_duration(d : float) -> void:
	if d >= 0.0:
		duration = d

func set_closed_message(m : String) -> void:
	closed_message = m
	if _interactable != null and not _door_open:
		_interactable.message = closed_message

func set_opened_message(m : String) -> void:
	opened_message = m
	if _interactable != null and _door_open:
		_interactable.message = opened_message

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_UpdateDoorNumber()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateDoorNumber() -> void:
	for idx : int in range(_text_object.size()):
		var mesh : MeshInstance3D = _text_object[idx]
		if mesh == null: continue
		mesh.visible = (idx == door_number)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interact(payload : Dictionary = {}) -> void:
	if Engine.is_editor_hint(): return
	if abs(open_angle) <= FLOAT_THRESHOLD: return
	
	var target_angle : float = 0.0 if _door_open else open_angle
	var dist : float = abs(target_angle - _motel_door.rotation.y)
	var dur : float = (dist / abs(open_angle)) * duration
	
	_door_open = not _door_open
	if _interactable != null:
		_interactable.message = opened_message if _door_open else closed_message
	if _collision != null:
		_collision.disabled = _door_open
	
	if _tween != null:
		_tween.kill()
		_tween = null
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_motel_door, "rotation:y", target_angle, dur)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
