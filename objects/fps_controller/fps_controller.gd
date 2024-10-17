extends CharacterBody3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const CAMERA_PITCH_ANGLE : float = deg_to_rad(70.0)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var speed : float = 5.0
@export var jump_speed : float = 5.0

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _mouse_rotation : Vector2 = Vector2.ZERO
var _mouse_sensitivity : Vector2 = Vector2(0.2, 0.2)

var _gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _input : Vector2 = Vector2.ZERO
var _look_input : Vector2 = Vector2.ZERO
var _jump : bool = false

var _interactable : Interactable = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _camera: Camera3D = $Camera
@onready var _camera_ray: RayCast3D = %CameraRay


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	MSense.sensitivity_changed.connect(_on_msense_sensitivity_changed)
	_mouse_sensitivity = MSense.get_sensitivity_vector()

func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#else:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion:
		_look_input = event.relative * _mouse_sensitivity
		#_UpdateView(event.relative * _mouse_sensitivity)
	elif event.is_action("move_forward") or event.is_action("move_backward") or event.is_action("move_left") or event.is_action("move_right"):
		_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

func _physics_process(delta: float) -> void:
	_CheckForInteractable()
	
	_UpdateView(delta)
	
	velocity.y += -_gravity * delta
	var move_dir : Vector3 = transform.basis * Vector3(_input.x, 0.0, _input.y)
	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed
	
	move_and_slide()
	if is_on_floor() and _jump:
		velocity.y = jump_speed
	_jump = false

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateView(delta : float) -> void:
	if _camera == null: return
	
	_mouse_rotation.x += -_look_input.y * delta
	_mouse_rotation.x = clampf(_mouse_rotation.x, -CAMERA_PITCH_ANGLE, CAMERA_PITCH_ANGLE)
	_mouse_rotation.y = wrapf(_mouse_rotation.y + (-_look_input.x * delta), 0.0, 2*PI)
	
	
	global_transform.basis = Basis.from_euler(Vector3(0.0, _mouse_rotation.y, 0.0))
	_camera.transform.basis = Basis.from_euler(Vector3(_mouse_rotation.x, 0.0, 0.0))
	_camera.rotation.z = 0.0
	
	_look_input = Vector2.ZERO


func _CheckForInteractable() -> void:
	if _camera_ray.is_colliding():
		var node : Node3D = _camera_ray.get_collider()
		if node is Interactable and node != _interactable:
			_interactable = node
			node.show_message()
	elif _interactable != null:
		_interactable.show_message(false)
		_interactable = null


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_msense_sensitivity_changed(sensitivity : Vector2) -> void:
	_mouse_sensitivity = sensitivity
