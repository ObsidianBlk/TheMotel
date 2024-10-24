extends Control
class_name InteractMessage

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Static Variables
# ------------------------------------------------------------------------------
static var _instance : InteractMessage = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _label: RichTextLabel = %RichTextLabel
@onready var _panel: PanelContainer = %PanelContainer
@onready var _arc: ArcProgress = %ArcProgress


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _enter_tree() -> void:
	if _instance == null:
		_instance = self

func _exit_tree() -> void:
	if _instance == self:
		_instance = null

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Static Public Methods
# ------------------------------------------------------------------------------
static func Set_Message(msg : String) -> void:
	if _instance != null:
		_instance.visible = true
		_instance.set_message(msg)

static func Set_Progress(progress : float) -> void:
	if _instance != null:
		_instance.visible = true
		_instance.set_progress(progress)

static func Hide_Message() -> void:
	if _instance != null:
		_instance.visible = false

static func Is_Showing() -> bool:
	if _instance != null:
		return _instance.visible
	return false

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func set_message(msg : String) -> void:
	if _label != null:
		_arc.visible = false
		_panel.visible = true
		_label.text = msg

func set_progress(progress : float) -> void:
	if _arc != null:
		_arc.visible = true
		_panel.visible = false
		_arc.value = _arc.max_value * progress

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
