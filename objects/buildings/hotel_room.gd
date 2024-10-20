@tool
extends Node3D

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var roof_node : Node3D = null:	set=set_roof_node
@export var hide_roof : bool = false:	set=set_hide_roof

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_roof_node(n : Node3D) -> void:
	roof_node = n
	_UpdateRoofVisibility()

func set_hide_roof(h : bool) -> void:
	hide_roof = h
	_UpdateRoofVisibility()


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _UpdateRoofVisibility() -> void:
	if roof_node == null: return
	if not Engine.is_editor_hint():
		roof_node.visible = true
	else:	
		roof_node.visible = not hide_roof
