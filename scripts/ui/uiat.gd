extends Object
class_name UIAT # UI Action Table

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const ACTION_QUIT_APPLICATION : StringName = &"quit_application"
const ACTION_QUIT_GAME : StringName = &"quit_game"

const ACTION_START_SINGLEPLAYER : StringName = &"start_singleplayer"
const ACTION_START_MULTIPLAYER : StringName = &"start_multiplayer"
const ACtION_RESUME_GAME : StringName = &"resume_game"
const ACTION_RESPAWN : StringName = &"respawn" 

const DIALOG_MODE_OK : int = 0
const DIALOG_MODE_YESNO : int = 1

const DIALOG_OPTION_MODE : StringName = &"dialog_mode"
const DIALOG_OPTION_FUNC_OK : StringName = &"func_ok"
const DIALOG_OPTION_FUNC_YES : StringName = &"func_yes"
const DIALOG_OPTION_FUNC_NO : StringName = &"func_no"
const DIALOG_OPTION_MESSAGE : StringName = &"dialog_message"

# ------------------------------------------------------------------------------
# Static Methods
# ------------------------------------------------------------------------------
static func DictHasKey(dict : Dictionary, key : StringName, type : int) -> bool:
	if key in dict:
		return typeof(dict[key]) == type
	return false
