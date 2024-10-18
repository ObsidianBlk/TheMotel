extends Node3D

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const CLOCKFACE_HOURS : int = 12
const CLOCKFACE_MINUTES : int = 60

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _clock_long_hand: Node3D = %ClockLongHand
@onready var _clock_short_hand: Node3D = %ClockShortHand


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Clock24.clock_ticked.connect(_on_clock_ticked)
	var minute : int = Clock24.get_minute()
	_UpdateShortHand(Clock24.get_hour_12(), minute)
	_UpdateLongHand(minute)


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateShortHand(hour : int, minutes : int) -> void:
	if _clock_short_hand == null: return
	var pm : float = float(minutes % CLOCKFACE_MINUTES) / float(CLOCKFACE_MINUTES)
	var subrot : float = deg_to_rad(30.0) * pm
	
	var p : float = float(hour % CLOCKFACE_HOURS) / float(CLOCKFACE_HOURS)
	var rot : float = ((2*PI) * p) + subrot
	_clock_short_hand.rotation.z = -rot

func _UpdateLongHand(minutes : int) -> void:
	if _clock_long_hand == null: return
	var p : float = float(minutes % CLOCKFACE_MINUTES) / float(CLOCKFACE_MINUTES)
	_clock_long_hand.rotation.z = (2 * PI) * -p

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_clock_ticked(hour : int, minute : int) -> void:
	_UpdateShortHand(hour, minute)
	_UpdateLongHand(minute)
