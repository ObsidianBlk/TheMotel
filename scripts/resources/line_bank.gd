extends Resource
class_name LineBank


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var lines : Array[String] = []

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_line_count() -> int:
	return lines.size()

func get_random_line() -> String:
	if lines.size() > 0:
		var idx : int = randi() % lines.size()
		return lines[idx]
	return ""
