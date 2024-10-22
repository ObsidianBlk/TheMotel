extends Node3D


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _interactable: Interactable = $Interactable


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interactable(payload : Dictionary = {}) -> void:
	_interactable.show_message(false)
	Game.send_action(Game.ACTION_SHOW_SCREEN, [&"NoteScreen"])
