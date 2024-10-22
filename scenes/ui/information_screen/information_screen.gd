@tool
extends UIControl


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const PANEL_NOTE : StringName = &"NotePanelContainer"
const PANEL_PAPER : StringName = &"PaperPanelContainer"

enum PanelType {NOTE=0, PAPER=1}


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var panel_type : PanelType = PanelType.NOTE:	set = set_panel_type
@export_multiline var note : String = "":				set = set_note
@export var exit_text : String = "":					set = set_exit_text


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _exit_action : StringName = &""
var _active : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _slideout_info: SlideoutContainer = %SlideoutInfo
@onready var _panel_container: PanelContainer = %PanelContainer
@onready var _label: RichTextLabel = %RichTextLabel
@onready var _btn_exit: Button = %BTN_Exit


# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_panel_type(t : PanelType) -> void:
	if panel_type != t:
		panel_type = t
		_UpdatePanelType()

func set_note(n : String) -> void:
	note = n
	_UpdateNoteLabel()

func set_exit_text(t : String) -> void:
	exit_text = t
	_UpdateExitText()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.is_editor_hint():
		super._ready()
	_UpdateNoteLabel()
	_UpdateExitText()
	_UpdatePanelType()

func _input(event: InputEvent) -> void:
	if not _active: return
	if event.is_action_pressed("ui_cancel"):
		_on_btn_exit_pressed()
		get_viewport().set_input_as_handled()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateNoteLabel() -> void:
	if _label == null: return
	_label.text = note

func _UpdateExitText() -> void:
	if _btn_exit == null: return
	if exit_text.is_empty():
		_btn_exit.text = "Exit"
	else:
		_btn_exit.text = exit_text

func _UpdatePanelType() -> void:
	if _panel_container == null: return
	match panel_type:
		PanelType.NOTE:
			_panel_container.theme_type_variation = PANEL_NOTE
		PanelType.PAPER:
			_panel_container.theme_type_variation = PANEL_PAPER

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func set_options(options : Dictionary) -> void:
	super.set_options(options)
	if UIAT.DictHasKey(options, &"exit_action", TYPE_STRING_NAME):
		_exit_action = options[&"exit_action"]


func on_reveal() -> void:
	_slideout_info.slide_amount = 1.0
	_slideout_info.slide_in()
	_btn_exit.grab_focus()
	_active = true
	super.on_reveal()

func on_hide() -> void:
	_active = false
	_slideout_info.slide_out()
	await _slideout_info.slide_finished
	super.on_hide()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_exit_pressed() -> void:
	await pop_ui()
	if not _exit_action.is_empty():
		request(_exit_action)
