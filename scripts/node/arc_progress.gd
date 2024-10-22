@tool
extends Control
class_name ArcProgress

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export_category("Arc Progress")
@export_subgroup("Arc")
@export var h_radius : float = 1.0:								set=set_h_radius
@export var v_radius : float = 1.0:								set=set_v_radius
@export_range(-360.0, 360.0) var start_degrees : float = 0.0:	set=set_start_degrees
@export_range(-360.0, 360.0) var end_degrees : float = 360.0:	set=set_end_degrees
@export var point_count : int = 16:								set=set_point_count
@export_subgroup("Display")
@export var outer_color : Color = Color.BLACK:					set=set_outer_color
@export var outer_thickness : float = -1.0:						set=set_outer_thickness
@export var inner_color : Color = Color.BLUE:					set=set_inner_color
@export var inner_thickness : float = -1.0:						set=set_inner_thickness
@export var anti_alias : bool = false:							set=set_anti_alias
@export_subgroup("Value Range")
@export var min_value : float = 0.0:							set=set_min_value
@export var max_value : float = 100.0:							set=set_max_value
@export var value : float = 50.0:								set=set_value

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _arc_size : Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_h_radius(hr : float) -> void:
	if hr <= 0.0: return
	h_radius = hr
	queue_redraw()

func set_v_radius(vr : float) -> void:
	if vr <= 0.0: return
	v_radius = vr
	queue_redraw()

func set_start_degrees(sd : float) -> void:
	if not (sd >= -360.0 and sd <= 360.0): return
	start_degrees = sd
	queue_redraw()

func set_end_degrees(ed : float) -> void:
	if not (ed >= -360.0 and ed <= 360.0): return
	end_degrees = ed
	queue_redraw()

func set_point_count(pc : int) -> void:
	if pc <= 0: return
	point_count = pc
	queue_redraw()

func set_outer_thickness(t : float) -> void:
	if t >= -1.0:
		outer_thickness = t
		queue_redraw()

func set_outer_color(c : Color) -> void:
	outer_color = c
	queue_redraw()

func set_inner_thickness(t : float) -> void:
	if t >= -1.0:
		inner_thickness = t
		queue_redraw()

func set_inner_color(c : Color) -> void:
	inner_color = c
	queue_redraw()

func set_anti_alias(aa : bool) -> void:
	anti_alias = aa
	queue_redraw()

func set_min_value(v : float) -> void:
	min_value = v
	if min_value > max_value:
		max_value = min_value
	if value < min_value:
		value = min_value
	queue_redraw()

func set_max_value(v : float) -> void:
	max_value = v
	if max_value < min_value:
		min_value = max_value
	if value > max_value:
		value = max_value
	queue_redraw()

func set_value(v : float) -> void:
	value = max(min_value, min(v, max_value))
	queue_redraw()

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------
func _draw() -> void:
	var ainfo : Dictionary = _GenerateEllipicalArc(
		Vector2(h_radius, v_radius),
		deg_to_rad(start_degrees),
		deg_to_rad(end_degrees),
		point_count,
		true
	)
	if ainfo.is_empty():
		printerr("Arc generated no points!")
		return
	
	var thickness : float = max(outer_thickness, inner_thickness)
	var min_bounds : Vector2 = -ainfo.min_bounds
	_arc_size = ainfo.size
	if thickness > 0.0:
		_arc_size += Vector2.ONE * thickness
		min_bounds += Vector2.ONE * (thickness * 0.5)
	
	_ShiftPoints(min_bounds, ainfo.points)
	
	var aa : bool = false if outer_thickness < 1.0 else anti_alias
	draw_polyline(ainfo.points, outer_color, outer_thickness, aa)
	
	var inner_end_degrees : float = _GetValueEndDegree()
	ainfo = _GenerateEllipicalArc(
		Vector2(h_radius, v_radius),
		deg_to_rad(start_degrees),
		deg_to_rad(inner_end_degrees),
		point_count
	)
	if ainfo.is_empty():
		printerr("Inner arc generated no points!")
		return
	_ShiftPoints(min_bounds, ainfo.points)
	
	aa = false if inner_thickness < 1.0 else anti_alias
	draw_polyline(ainfo.points, inner_color, inner_thickness, aa)
	(func(obj : Control):
		obj.update_minimum_size()
	).call_deferred(self)

func _get_minimum_size() -> Vector2:
	return _arc_size

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _GenerateEllipicalArc(arc_radii : Vector2, start_angle : float, end_angle : float, count : int, calc_arc_size : bool = false) -> Dictionary:
	if count <= 0: return {}
	var points : Array[Vector2] = []
	
	var xbounds : Vector2 = Vector2.ZERO
	var ybounds : Vector2 = Vector2.ZERO
	
	var rx : float = arc_radii.x
	var ry : float = arc_radii.y
	
	var ang_adj : float = (end_angle - start_angle) / count
	
	for i in range(count + 1):
		var ang : float = start_angle + (ang_adj * i)
		var x : float = rx * cos(ang)
		var y : float = ry * sin(ang)
		
		if calc_arc_size:
			#print("Y Bounds: ", ybounds, " | Y: ", y)
			if i == 0:
				xbounds = Vector2(x, x)
				ybounds = Vector2(y, y)
			else:
				xbounds.x = xbounds.x if x > xbounds.x else x
				xbounds.y = xbounds.y if x < xbounds.y else x
				ybounds.x = ybounds.x if y > ybounds.x else y
				ybounds.y = ybounds.y if y < ybounds.y else y
		
		points.append(Vector2(x,y))
	
	var min_bounds : Vector2 = Vector2(xbounds.x, ybounds.x)
	var arc_size : Vector2 = Vector2(
		xbounds.y - xbounds.x,
		ybounds.y - ybounds.x
	)
	return {
		"points": PackedVector2Array(points),
		"size": arc_size,
		"min_bounds" : min_bounds
	}

func _ShiftPoints(to : Vector2, points : PackedVector2Array) -> void:
	for i in range(points.size()):
		points[i] += to

func _GetValueEndDegree() -> float:
	var deg_dist : float = end_degrees - start_degrees
	var val_range : float = max_value - min_value
	var p : float = (value - min_value) / val_range
	return start_degrees + (deg_dist * p)

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------



