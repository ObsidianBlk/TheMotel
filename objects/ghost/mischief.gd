extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const GROUP_ROOM_LAMP : StringName = &"RoomLamp"
const GROUP_ROOM_AC : StringName = &"RoomAC"

const MAX_DISTANCE : float = 8.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


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
func _GetClosestLamp() -> Lamp:
	var lamps : Array[Node] = get_tree().get_nodes_in_group(GROUP_ROOM_LAMP)
	lamps = lamps.filter(func(item : Node): return item is Lamp)
	var closest : Lamp = null
	var closest_dist : float = INF
	for lamp : Lamp in lamps:
		var dist : float = lamp.global_position.distance_to(global_position)
		if dist <= MAX_DISTANCE and dist < closest_dist:
			closest_dist = dist
			closest = lamp
	return closest

#func _BreakRandomLamp() -> void:
	#var lamps : Array[Node] = get_tree().get_nodes_in_group(GROUP_ROOM_LAMP)
	#lamps = lamps.filter(func(item : Node): return item is Lamp)
	#if lamps.size() > 0:
		#var idx = randi() % lamps.size()
		#lamps[idx].functional = false

func _GetClosestAC() -> AirConditioner:
	var ac : Array[Node] = get_tree().get_nodes_in_group(GROUP_ROOM_AC)
	ac = ac.filter(func(item : Node): return item is AirConditioner)
	var closest : AirConditioner
	var closest_dist : float = INF
	for a : AirConditioner in ac:
		var dist : float = a.global_position.distance_to(global_position)
		if dist <= MAX_DISTANCE and dist < closest_dist:
			closest = a
			closest_dist = dist
	return closest

func _BreakLamp(lamp : Lamp) -> void:
	if lamp == null: return
	lamp.enabled = false
	lamp.functional = false

func _BreakAC(ac : AirConditioner) -> void:
	if ac == null: return
	ac.enabled = false
	ac.state = AirConditioner.State.BROKEN

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func trigger() -> void:
	var lamp : Lamp = _GetClosestLamp()
	var ac : AirConditioner = _GetClosestAC()
	if lamp == null and ac == null: return
	var which : float = randf()
	if which <= 0.5 or ac == null:
		print("Ghost Breaks Lamp")
		_BreakLamp(lamp)
	elif which > 0.5 or lamp == null:
		print("Ghost Breaks AC")
		_BreakAC(ac)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
