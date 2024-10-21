extends UIControl

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
const MODULATE_COLOR_INVISIBLE : Color = Color(1.0, 1.0, 1.0, 0.0)
const MODULATE_COLOR_VISIBLE : Color = Color.WHITE

const LINE_DISPLAY_DURATION : float = 2.0
const LINE_CHANGE_DELAY : float = 0.5

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var lines : LineBank = null
@export var duration_in : float = 0.5
@export var duration_out : float = 0.25


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _active : bool = false
var _line_delay : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _lbl_load_line: Label = %LBL_LoadLine
@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var _mc: MarginContainer = $MC


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	if not _active or _lbl_load_line == null: return
	if is_equal_approx(_lbl_load_line.visible_ratio, 1.0):
		_line_delay = clampf(_line_delay + delta, 0.0, LINE_CHANGE_DELAY)
		if is_equal_approx(_line_delay, LINE_CHANGE_DELAY):
			_lbl_load_line.visible_ratio = 0.0
			_lbl_load_line.text = _GetRandomLine()
			_line_delay = 0.0
	else:
		_line_delay = clampf(_line_delay + delta, 0.0, LINE_DISPLAY_DURATION)
		_lbl_load_line.visible_ratio = clampf(_line_delay / LINE_DISPLAY_DURATION, 0.0, 1.0)
		if is_equal_approx(_line_delay, LINE_DISPLAY_DURATION):
			_line_delay = 0.0

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _TweenTo(mod_color : Color, duration : float) -> Tween:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_mc, "modulate", mod_color, duration)
	return tween

func _GetRandomLine() -> String:
	if lines != null:
		if lines.get_line_count() >= 0:
			return lines.get_random_line()
	return "Loading..."

# ------------------------------------------------------------------------------
# "Virtual" Methods
# ------------------------------------------------------------------------------
func on_reveal() -> void:
	register_action_handler(UIAT.ACTION_UPDATE_LOAD_PROGRESS, update_progress)
	_active = true
	_mc.modulate = MODULATE_COLOR_INVISIBLE
	_lbl_load_line.visible_ratio = 0.0
	_lbl_load_line.text = _GetRandomLine()
	_TweenTo(MODULATE_COLOR_VISIBLE, duration_in)
	super.on_reveal()

func on_hide() -> void:
	_active = false
	unregister_action_handler(UIAT.ACTION_UPDATE_LOAD_PROGRESS, update_progress)
	await _TweenTo(MODULATE_COLOR_INVISIBLE, duration_out).finished
	super.on_hide()

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func update_progress(progress : float) -> void:
	_progress_bar.value = progress * _progress_bar.max_value
