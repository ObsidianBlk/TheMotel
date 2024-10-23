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

var _broken_lamps : Dictionary = {}
var _broken_ac : Dictionary = {}

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
	_wrc.add_entry(ACTION_NOTHING, 50)
	_wrc.add_entry(ACTION_POWEROUT, 10)
	
	_ConnectAC()
	_ConnectLamps()
	
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
		#print("Clown Time: ", _clown_time)
		if _clown_time >=CLOWN_MUSIC_TIME:
			dark_music_requested.emit(true)
		if _clown_time >= CLOWN_ACTIVE_TIME:
			Game.send_action(UIAT.ACTION_QUIT_GAME, [&"ClownScreen", Game.BACKDROP_CLOWN])

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ConnectLamps() -> void:
	var lamps : Array[Node] = get_tree().get_nodes_in_group(GROUP_ROOM_LAMP)
	lamps = lamps.filter(func(item : Node): return item is Lamp)
	for idx : int in range(lamps.size()):
		var lamp : Lamp = lamps[idx]
		if not lamp.functional_changed.is_connected(_on_lamp_functional_changed.bind(idx)):
			lamp.functional_changed.connect(_on_lamp_functional_changed.bind(idx))

func _ConnectAC() -> void:
	var acl : Array[Node] = get_tree().get_nodes_in_group(GROUP_ROOM_AC)
	acl = acl.filter(func(item : Node): return item is AirConditioner)
	for idx : int in range(acl.size()):
		var ac : AirConditioner = acl[idx]
		if not ac.state_changed.is_connected(_on_ac_state_changed.bind(idx)):
			ac.state_changed.connect(_on_ac_state_changed.bind(idx))

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
		var total_broken : int = _broken_ac.size() + _broken_lamps.size()
		if total_broken > 3:
			Game.send_action(UIAT.ACTION_QUIT_GAME, [&"OOTScreen", Game.BACKDROP_GHOST])
		else:
			Game.send_action(UIAT.ACTION_QUIT_GAME, [&"GoodJobScreen", Game.BACKDROP_GHOST])

func _on_creepy_clown_returned_home() -> void:
	_clown_active = false
	dark_music_requested.emit(false)

func _on_creepy_clown_transported() -> void:
	_clown_active = true
	_clown_time = 0.0

func _on_lamp_functional_changed(is_functional : bool, lamp_idx : int) -> void:
	if not is_functional:
		_broken_lamps[lamp_idx] = true
	elif lamp_idx in _broken_lamps:
		_broken_lamps.erase(lamp_idx)
	print("Total Broken Lamps: ", _broken_lamps.size())

func _on_ac_state_changed(state : AirConditioner.State, ac_idx : int) -> void:
	if state == AirConditioner.State.BROKEN:
		_broken_ac[ac_idx] = true
	elif ac_idx in _broken_ac:
		_broken_ac.erase(ac_idx)
	print("Total Broken AC: ", _broken_ac.size())
