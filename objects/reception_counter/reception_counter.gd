extends Node3D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const OPEN_ANGLE : float = deg_to_rad(-112.0)
const TOTAL_DURATION : float = 1.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_multiline var opened_message : String = "":			set = set_opened_message
@export_multiline var closed_message : String = "":			set = set_closed_message

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _tween : Tween = null
var _opened : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _leaf: Node3D = %ReceptionCounterLeaf
@onready var _interactable: Interactable = %Interactable

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_opened_message(m : String) -> void:
	opened_message = m
	_UpdateInteractMessage()

func set_closed_message(m : String) -> void:
	closed_message = m
	_UpdateInteractMessage()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateInteractMessage() -> void:
	if _interactable == null: return
	if _opened:
		_interactable.message = opened_message
	else:
		_interactable.message = closed_message

func _Toggle() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
	
	var total_dist = abs(OPEN_ANGLE)
	var target : float = OPEN_ANGLE if is_equal_approx(_leaf.rotation.z, 0.0) else 0
	var dist : float = abs(_leaf.rotation.z - target)
	var duration : float = (dist / total_dist) * TOTAL_DURATION
	
	_opened = not is_equal_approx(target, 0.0)
	_UpdateInteractMessage()
	
	_tween = create_tween()
	_tween.tween_property(_leaf, "rotation:z", target, duration)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_QUART)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interact(payload : Dictionary = {}) -> void:
	_Toggle()
