extends UIControl


const URL_ITCHIO_OBSIDIANBLK : String = "https://obsidianblk.itch.io/"
const URL_ITCHIO_COBOLTGAMES : String = "https://coboltgames.itch.io/"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var options_menu : StringName = &""


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _slideout_menu: SlideoutContainer = %SlideoutMenu
@onready var _slideout_logos: SlideoutContainer = %SlideoutLogos

@onready var _btn_start_game: Button = %BTN_StartGame


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func on_reveal() -> void:
	_slideout_menu.slide_amount = 1.0
	_slideout_logos.slide_amount = 1.0
	_slideout_menu.slide_in()
	_slideout_logos.slide_in()
	_btn_start_game.grab_focus()
	super.on_reveal()

func on_hide() -> void:
	_slideout_menu.slide_out()
	_slideout_logos.slide_out()
	await _slideout_menu.slide_finished
	super.on_hide()

# ------------------------------------------------------------------------------
# Handler Variables
# ------------------------------------------------------------------------------

func _on_btn_start_game_pressed() -> void:
	await pop_ui()
	request(UIAT.ACTION_START_SINGLEPLAYER)


func _on_btn_options_pressed() -> void:
	if not options_menu.is_empty():
		swap_ui(options_menu, false, {OPTION_PREVIOUS_MENU: name})


func _on_btn_quit_pressed() -> void:
	await pop_ui()
	request(UIAT.ACTION_QUIT_APPLICATION)


func _on_btn_obsidian_blk_pressed() -> void:
	OS.shell_open(URL_ITCHIO_OBSIDIANBLK)


func _on_btn_cobolt_games_pressed() -> void:
	OS.shell_open(URL_ITCHIO_COBOLTGAMES)
