extends UIControl


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var options_menu : StringName = &""


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _slideout_menu: SlideoutContainer = %SlideoutMenu
@onready var _btn_resume: Button = %BTN_Resume

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	set_process_input(false)
	super._ready()

func _input(event: InputEvent) -> void:
	if not is_equal_approx(_slideout_menu.slide_amount, 0.0): return
	if event.is_action_pressed("ui_cancel"):
		_on_btn_resume_pressed.call_deferred()
		get_viewport().set_input_as_handled()

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func on_reveal() -> void:
	_slideout_menu.slide_amount = 1.0
	_slideout_menu.slide_in()
	_btn_resume.grab_focus()
	set_process_input(true)
	super.on_reveal()

func on_hide() -> void:
	set_process_input(false)
	_slideout_menu.slide_out()
	await _slideout_menu.slide_finished
	super.on_hide()

# ------------------------------------------------------------------------------
# Handler Variables
# ------------------------------------------------------------------------------

func _on_btn_resume_pressed() -> void:
	await pop_ui()
	request(UIAT.ACtION_RESUME_GAME)


func _on_btn_options_pressed() -> void:
	if not options_menu.is_empty():
		swap_ui(options_menu, false, {OPTION_PREVIOUS_MENU: name})


func _on_btn_quit_pressed() -> void:
	await pop_ui()
	request(UIAT.ACTION_QUIT_GAME)
