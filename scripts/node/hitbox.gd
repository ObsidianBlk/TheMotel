extends Area3D
class_name Hitbox

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var group : StringName = &"":		set = set_group

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_group(g : StringName) -> void:
	if not group.is_empty():
		remove_from_group(group)
	group = g
	if not group.is_empty():
		add_to_group(group)

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	if not group.is_empty():
		if not is_in_group(group):
			add_to_group(group)
