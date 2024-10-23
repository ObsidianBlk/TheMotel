extends Level

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal dark_music_requested(active : bool)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const GROUP_ROOM_LAMP : StringName = &"RoomLamp"
const GROUP_ROOM_AC : StringName = &"RoomAC"

const CLOWN_ACTIVE_TIME : float = 120.0 # Two minutes
const CLOWN_MUSIC_TIME : float = 70.0

const ACTION_NOTHING : StringName = &"nothing"
const ACTION_POWEROUT : StringName = &"powerout"

const POWEROUT_WAIT : float = 30.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _clown_active : bool = false
var _clown_time : float = 0.0

var _wrc : WeightedRandomCollection = null
var _pow : float = 0.0

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
	_wrc = WeightedRandomCollection.new()
	_wrc.add_entry(ACTION_NOTHING, 100)
	_wrc.add_entry(ACTION_POWEROUT, 10)
	
	_BreakRandomAC()
	_BreakRandomLamp()

func _process(delta: float) -> void:
	if _wrc != null:
		if _pow >= POWEROUT_WAIT:
			var action : StringName = _wrc.get_random()
			if action == ACTION_POWEROUT:
				var has_powerout : bool = Game.player_has_item(Game.INV_OBJECT_POWEROUT)
				var has_flashlight : bool = Game.player_has_item(Game.INV_OBJECT_FLASHLIGHT)
				if has_flashlight and not has_powerout:
					Game.add_player_item(Game.INV_OBJECT_POWEROUT)
			_pow = 0.0
		else: _pow += delta
	
	if _clown_active:
		_clown_time += delta
		print("Clown Time: ", _clown_time)
		if _clown_time >=CLOWN_MUSIC_TIME:
			dark_music_requested.emit(true)
		if _clown_time >= CLOWN_ACTIVE_TIME:
			Game.send_action(UIAT.ACTION_QUIT_GAME, [&"ClownScreen", Game.BACKDROP_CLOWN])

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
		Game.send_action(UIAT.ACTION_QUIT_GAME, [&"OOTScreen", Game.BACKDROP_GHOST])

func _on_creepy_clown_returned_home() -> void:
	_clown_active = false
	dark_music_requested.emit(false)

func _on_creepy_clown_transported() -> void:
	_clown_active = true
	_clown_time = 0.0
