extends CanvasLayer
class_name UILayer


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
#signal action_requested(action : StringName, args : Array)
signal ui_revealed(ui_name : StringName)
signal ui_hidden(ui_name : StringName)
signal all_ui_hidden()

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("UI Canvas Layer")
@export var initial_ui : StringName = &""
@export var immediate_open : bool = false
@export var default_ui : StringName = &""

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _ui_children : Dictionary = {}
var _active : Dictionary = {}

var _registered_actions : Dictionary = {}

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	for child : Node in get_children():
		_on_child_entered_tree(child)
	register_action_handler(UIControl.ACTION_OPEN_UI, open_ui)
	register_action_handler(UIControl.ACTION_CLOSE_UI, close_ui)
	register_action_handler(UIControl.ACTION_CLOSE_ALL_UI, close_all_ui)
	register_action_handler(UIControl.ACTION_REGISTER_HANDLER, register_action_handler)
	register_action_handler(UIControl.ACTION_UNREGISTER_HANDLER, unregister_action_handler)
	
	open_ui(initial_ui, immediate_open)


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func register_action_handler(action : StringName, handler : Callable) -> int:
	if action.strip_edges().is_empty() or handler == null: return ERR_INVALID_PARAMETER
	if not action in _registered_actions:
		_registered_actions[action] = []
	if _registered_actions[action].find(handler) >= 0:
		return ERR_ALREADY_EXISTS
	_registered_actions[action].append(handler)
	return OK

func unregister_action_handler(action : StringName, handler : Callable) -> void:
	if not action in _registered_actions: return
	
	var idx : int = _registered_actions[action].find(handler)
	if idx < 0: return
	
	_registered_actions[action].remove_at(idx)
	if _registered_actions[action].size() <= 0:
		_registered_actions.erase(action)

func open_ui(ui_name : StringName, immediate : bool = false, options : Dictionary = {}) -> void:
	if ui_name in _ui_children:
		if ui_name in _active: return
		_ui_children[ui_name].reveal_ui(immediate, options)
		_active[ui_name] = _ui_children[ui_name]

func open_default_ui() -> void:
	if not default_ui.is_empty():
		open_ui(default_ui)

func close_ui(ui_name : StringName, immediate : bool = false) -> void:
	if ui_name in _active:
		_active[ui_name].hide_ui(immediate)
	

func close_all_ui(immediate : bool = false) -> void:
	for ui_name : StringName in _active.keys():
		close_ui(ui_name, immediate)

func get_ui_list() -> Array[StringName]:
	var arr : Array[StringName] = []
	arr.assign(_ui_children.keys())
	return arr

func get_active_ui() -> Array[StringName]:
	var arr : Array[StringName] = []
	arr.assign(_active.keys())
	return arr

func is_ui_active(ui_name : StringName) -> bool:
	return ui_name in _active

func ui_active() -> bool:
	return get_active_ui().size() > 0

func call_action(action_name : StringName, args : Array = []) -> void:
	_on_action_requested(action_name, args)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_child_entered_tree(child : Node) -> void:
	if not child is UIControl: return
	if child.name in _ui_children:
		printerr("UI named, ", child.name, ", already registered with UI Canvas Layer, ", name)
		return
	
	_ui_children[child.name] = child
	if child.visible:
		_active[child.name] = child
	
	if not child.action_requested.is_connected(_on_action_requested):
		child.action_requested.connect(_on_action_requested)
	if not child.ui_revealed.is_connected(_on_ui_revealed.bind(child.name)):
		child.ui_revealed.connect(_on_ui_revealed.bind(child.name))
	if not child.ui_hidden.is_connected(_on_ui_hidden.bind(child.name)):
		child.ui_hidden.connect(_on_ui_hidden.bind(child.name))

func _on_child_exiting_tree(child : Node) -> void:
	if not child is UIControl: return
	if child.name in _ui_children:
		_ui_children.erase(child.name)
	if child.name in _active:
		_active.erase(child.name)
	
	if child.action_requested.is_connected(_on_action_requested):
		child.action_requested.disconnect(_on_action_requested)
	if child.ui_revealed.is_connected(_on_ui_revealed.bind(child.name)):
		child.ui_revealed.disconnect(_on_ui_revealed.bind(child.name))
	if child.ui_hidden.is_connected(_on_ui_hidden.bind(child.name)):
		child.ui_hidden.disconnect(_on_ui_hidden.bind(child.name))

func _on_action_requested(action : StringName, args : Array) -> void:
	if action in _registered_actions:
		for fn : Callable in _registered_actions[action]:
			fn.callv(args)

func _on_ui_revealed(ui_name : StringName) -> void:
	ui_revealed.emit(ui_name)

func _on_ui_hidden(ui_name : StringName) -> void:
	ui_hidden.emit(ui_name)
	if ui_name in _active:
		_active.erase(ui_name)
	if _active.size() <= 0:
		all_ui_hidden.emit()
