extends Control
class_name UIControl


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal action_requested(action : StringName, args : Array)
signal ui_revealed()
signal ui_hidden()

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const ACTION_OPEN_UI : StringName = &"reveal_ui"
const ACTION_CLOSE_UI : StringName = &"hide_ui"
const ACTION_CLOSE_ALL_UI : StringName = &"hide_all_ui"

const OPTION_PREVIOUS_MENU : String = "previous_menu"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("UI Control")
@export var initialize_hidden : bool = true

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _prev_menu : StringName = &""

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if initialize_hidden:
		visible = false
		#hide_ui(true)
	else:
		reveal_ui(true)

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func reveal_ui(immediate : bool = false, options : Dictionary = {}) -> void:
	if not visible:
		(func():
			set_options(options)
			visible = true
			on_reveal()
		).call_deferred()

func hide_ui(immediate : bool = false) -> void:
	if visible:
		(func():
			await on_hide()
			visible = false
		).call_deferred()

func on_reveal() -> void:
	ui_revealed.emit()

func on_hide() -> void:
	ui_hidden.emit()

func set_options(options : Dictionary) -> void:
	if UIAT.DictHasKey(options, OPTION_PREVIOUS_MENU, TYPE_STRING_NAME):
		_prev_menu = options[OPTION_PREVIOUS_MENU]

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func request(action : StringName, args : Array = []) -> void:
	action_requested.emit(action, args)

func open_ui(ui_name : StringName, immediate : bool = false, options : Dictionary = {}) -> void:
	request(ACTION_OPEN_UI, [ui_name, immediate, options])

func close_ui(ui_name : StringName, immediate : bool = false) -> void:
	request(ACTION_CLOSE_UI, [ui_name, immediate])

func swap_ui(to_ui : StringName, immediate : bool = false, options : Dictionary = {}) -> void:
	request(ACTION_CLOSE_UI, [name, immediate])
	if not immediate:
		await ui_hidden
	request(ACTION_OPEN_UI, [to_ui, immediate, options])

func pop_ui(immediate : bool = false, options : Dictionary = {}) -> void:
	if _prev_menu.is_empty():
		close_ui(name, immediate)
		if not immediate:
			await ui_hidden
	else:
		swap_ui(_prev_menu, immediate, options)
