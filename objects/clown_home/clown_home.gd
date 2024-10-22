extends Node3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const GROUP_CLOWN : StringName = &"Clown"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
@onready var _interactable: Interactable = $Interactable
@onready var _editor_ref: CSGBox3D = $EditorRef


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	Game.player_inventory_item_added.connect(_on_player_item_changed.bind(true))
	Game.player_inventory_item_removed.connect(_on_player_item_changed.bind(false))
	_editor_ref.visible = false
	_on_player_item_changed(Game.INV_OBJECT_CLOWN, Game.player_has_item(Game.INV_OBJECT_CLOWN))

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _ReturnClown() -> void:
	var cl : Array[Node] = get_tree().get_nodes_in_group(GROUP_CLOWN)
	if cl.size() > 0:
		if cl[0] is Node3D:
			cl[0].global_position = global_position
			cl[0].global_basis = Basis(global_basis)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func interact(playload : Dictionary = {}) -> void:
	if Game.player_has_item(Game.INV_OBJECT_CLOWN):
		Game.remove_player_item(Game.INV_OBJECT_CLOWN)
		_ReturnClown()

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_player_item_changed(item_name : StringName, item_added : bool) -> void:
	if item_name == Game.INV_OBJECT_CLOWN:
		if not item_added:
			_interactable.show_message(false)
		_interactable.enabled = item_added
