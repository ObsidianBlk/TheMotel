extends Area3D

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------
signal lights_changed(lights_on : bool)

# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _region : Region = null
var _lights_on : bool = false

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _ready() -> void:
	area_entered.connect(_on_area_entered)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DisconnectRegion() -> void:
	if _region == null: return
	if _region.lights_changed.is_connected(_on_region_lights_changed):
		_region.lights_changed.disconnect(_on_region_lights_changed)

func _ConnectRegion() -> void:
	if _region == null: return
	print("Connecting to Region: ", _region.name)
	if not _region.lights_changed.is_connected(_on_region_lights_changed):
		_region.lights_changed.connect(_on_region_lights_changed)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
func _on_area_entered(area : Area3D) -> void:
	if area is Region and area != _region:
		_DisconnectRegion()
		_region = area
		_ConnectRegion()
		_on_region_lights_changed(_region.lights_on)

func _on_region_lights_changed(lights_on : bool) -> void:
	if lights_on != _lights_on:
		_lights_on = lights_on
		lights_changed.emit(_lights_on)
