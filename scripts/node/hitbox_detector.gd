extends Area3D
class_name HitboxDetector


# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal hitbox_detected(hitbox : Hitbox)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var group : StringName = &""


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	area_entered.connect(_on_area_entered)

# ------------------------------------------------------------------------------
# Hander Methods
# ------------------------------------------------------------------------------
func _on_area_entered(area : Area3D) -> void:
	if area is Hitbox:
		if area.group == group:
			hitbox_detected.emit(area)

#func _on_area_exited(area : Area3D) -> void:
	#pass
