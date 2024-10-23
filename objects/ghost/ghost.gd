extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const GROUP_NAV : StringName = &"GhostPath"
const GROUP_PLAYER : StringName = &"Player"

const MOVE_SPEED : float = 2.0

const WAIT_TIME_MIN : float = 1.0
const WAIT_TIME_MAX : float = 4.0

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var always_visible : bool = false
@export var max_alpha : float = 1.0
@export var min_distance : float = 4.0
@export var max_distance : float = 8.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _player : WeakRef = weakref(null)
var _need_dest : bool = true
var _wait : bool = false
var _lights_out : bool = true

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _ghost: AnimatedSprite3D = $Ghost
@onready var _agent: NavigationAgent3D = $Agent
@onready var _camp_timer: Timer = $CampTimer
@onready var _asp_footsteps: AudioStreamPlayer3D = $ASP_Footsteps
@onready var _anim_footsteps: AnimationPlayer = $Anim_Footsteps
@onready var _mischief: Node3D = $Mischief


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_anim_footsteps.play(&"footsteps")

func _physics_process(delta: float) -> void:
	_UpdateGhostVis()
	if _agent != null:
		if _need_dest:
			if not _wait:
				_FindNewDestination()
		else:
			var pos : Vector3 = _agent.get_next_path_position()
			var dist : float = global_position.distance_to(pos)
			
			var speed : float = min(MOVE_SPEED * delta, dist)
			var direction : Vector3 = global_position.direction_to(pos) * speed
			direction.y = 0.0
			
			global_position += direction

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetPlayer() -> Node3D:
	var player : Node3D = _player.get_ref()
	if player == null:
		var plist : Array = get_tree().get_nodes_in_group(GROUP_PLAYER)
		if plist.size() > 0:
			player = plist[0]
			_player = weakref(player)
	return player

func _UpdateGhostVis() -> void:
	if always_visible:
		_ghost.modulate = Color(1.0, 1.0, 1.0, 1.0)
		return
		
	if _lights_out:
		var player = _GetPlayer()
		if player == null:
			_ghost.modulate = Color(1.0, 1.0, 1.0, 0.0)
			return
		var alpha : float = _AlphaFromDistance(global_position, player.global_position)
		_ghost.modulate = Color(1.0, 1.0, 1.0, alpha)
		#_player_ray.look_at(player.global_position)
	else:
		_ghost.modulate = Color(1.0, 1.0, 1.0, 0.0)

func _FindNewDestination() -> void:
	var dstlist : Array = get_tree().get_nodes_in_group(GROUP_NAV)
	if dstlist.size() <= 1 : return
	var didx : int = randi() % dstlist.size()
	if dstlist[didx] is Node3D:
		_agent.target_position = dstlist[didx].global_position
	_need_dest = false

func _WaitAtTarget() -> void:
	_need_dest = true
	_wait = true
	if randf() < 0.5:
		print("Ghost Mischief")
		_mischief.trigger()
	_camp_timer.start(randf_range(WAIT_TIME_MIN, WAIT_TIME_MAX))

func _AlphaFromDistance(from : Vector3, to : Vector3) -> float:
	var dist = from.distance_to(to)
	var total_dist : float = max_distance - min_distance
	if total_dist == 0.0: return 0.0
	var mid_dist : float = min_distance + (total_dist * 0.5)
	var alpha : float = 0.0
	if dist <= mid_dist:
		alpha = smoothstep(min_distance, mid_dist, dist)
	else:
		alpha = 1.0 - smoothstep(mid_dist, max_distance, dist)
	return alpha * max_alpha
	#return clampf((dist - min_distance) / total_dist, 0.0, 1.0)

func _TakeStep() -> void:
	if not _lights_out or _wait: return
	_asp_footsteps.play()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------

func _on_agent_navigation_finished() -> void:
	_WaitAtTarget()

func _on_camp_timer_timeout() -> void:
	_wait = false
