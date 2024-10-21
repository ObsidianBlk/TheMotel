extends Resource
class_name LineBank


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var lines : Array[String] = []

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _idx_used : Array[int] = []

# ------------------------------------------------------------------------------
# Setters
# ------------------------------------------------------------------------------
func set_lines(l : Array[String]) -> void:
	lines = l
	_idx_used.clear()

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GetAvailableIndexes() -> Array[int]:
	if lines.size() <= 0: return []
	var arr : Array[int] = []
	arr.assign(
		range(lines.size()).filter(func(idx : int): return _idx_used.find(idx) < 0)
	)
	return arr

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func get_line_count() -> int:
	return lines.size()

func get_random_line() -> String:
	if lines.size() > 0:
		var available : Array[int] = _GetAvailableIndexes()
		var idx : int = 0
		if available.size() > 0:
			var aidx : int = randi() % available.size()
			idx = available[aidx]
		else:
			_idx_used.clear()
			idx = randi() % lines.size()
		_idx_used.append(idx)
		return lines[idx]
	return ""
