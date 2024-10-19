extends UIControl

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
# Variables
# ------------------------------------------------------------------------------
var _active_option : Control = null

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _slideout_groups: SlideoutContainer = %SlideoutGroups
@onready var _slideout_options: SlideoutContainer = %SlideoutOptions

@onready var _btn_gameplay: Button = %BTN_Gameplay
@onready var _btn_audio: Button = %BTN_Audio

@onready var _options_audio: PanelContainer = %OptionsAudio
@onready var _options_gameplay: PanelContainer = %OptionsGameplay



# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	_HideAll()
	super._ready()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _HideAll() -> void:
	_options_audio.visible = false
	_options_gameplay.visible = false

func _InitialOptionGroupReveal() -> void:
	if _btn_gameplay.button_pressed:
		_btn_gameplay.grab_focus()
		_on_btn_gameplay_pressed()
	elif _btn_audio.button_pressed:
		_btn_audio.grab_focus()
		_on_btn_audio_pressed()

func _ChangeActiveOptionGroup(op : Control) -> void:
	if _active_option != null and _active_option != op:
		_slideout_options.slide_out()
		await _slideout_options.slide_finished
		_active_option.visible = false
	_active_option = op
	_active_option.visible = true
	_slideout_options.slide_in()

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func on_reveal() -> void:
	_slideout_options.slide_amount = 1.0
	_slideout_groups.slide_amount = 1.0
	_slideout_groups.slide_finished.connect(_InitialOptionGroupReveal, CONNECT_ONE_SHOT)
	_slideout_groups.slide_in()
	super.on_reveal()

func on_hide() -> void:
	_slideout_options.slide_out()
	await _slideout_options.slide_finished
	if _active_option != null:
		_active_option.visible = false
		_active_option = null
	
	_slideout_groups.slide_out()
	await _slideout_groups.slide_finished
	super.on_hide()


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_btn_apply_pressed() -> void:
	Settings.save()
	pop_ui()

func _on_btn_audio_pressed() -> void:
	_ChangeActiveOptionGroup(_options_audio)

func _on_btn_gameplay_pressed() -> void:
	_ChangeActiveOptionGroup(_options_gameplay)
