extends Level

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const GROUP_ROOM_LAMP : StringName = &"RoomLamp"
const GROUP_ROOM_AC : StringName = &"RoomAC"

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
func _ready() -> void:
	Clock24.clock_ticked.connect(_on_clock_tick)
	_BreakRandomAC()
	_BreakRandomLamp()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _BreakRandomLamp() -> void:
	var lamps : Array[Node] = get_tree().get_nodes_in_group(GROUP_ROOM_LAMP)
	lamps = lamps.filter(func(item : Node): return item is Lamp)
	if lamps.size() > 0:
		print("Getting random lamp")
		var idx = randi() % lamps.size()
		lamps[idx].functional = false

func _BreakRandomAC() -> void:
	var ac : Array[Node] = get_tree().get_nodes_in_group(GROUP_ROOM_AC)
	ac = ac.filter(func(item : Node): return item is AirConditioner)
	if ac.size() > 0:
		var idx = randi() % ac.size()
		ac[idx].state = AirConditioner.State.BROKEN

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_clock_tick(hour : int, minutes: int) -> void:
	if hour == 6:
		Game.send_action(UIAT.ACTION_QUIT_GAME, [&"OOTScreen"])

func _on_creepy_clown_returned_home() -> void:
	pass # Replace with function body.

func _on_creepy_clown_transported() -> void:
	pass # Replace with function body.
