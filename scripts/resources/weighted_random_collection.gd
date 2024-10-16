@tool
extends Resource
class_name WeightedRandomCollection

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Constants and ENUMs
# ------------------------------------------------------------------------------
const DICT_KEY_ID : StringName = &"ID"
const DICT_KEY_WEIGHT : StringName = &"Weight"
const DICT_KEY_ACCUM : StringName = &"Accum"

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------
@export var collection : Array[Dictionary]:		set=set_collection, get=get_collection

# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
var _collection : Array[Dictionary] = []
var _accum_weight : float = 0.0

# ------------------------------------------------------------------------------
# Onready Variables
# ------------------------------------------------------------------------------
func _init(coll : Array[Dictionary] = []) -> void:
	if coll.size() > 0:
		set_collection(coll)

# ------------------------------------------------------------------------------
# Setters / Getters
# ------------------------------------------------------------------------------
func set_collection(c : Array[Dictionary]) -> void:
	clear()
	for item : Dictionary in c:
		if DICT_KEY_ID in item and _DictHasKeyType(item, DICT_KEY_WEIGHT, TYPE_FLOAT):
			add_entry(item[DICT_KEY_ID], item[DICT_KEY_WEIGHT])
		

func get_collection() -> Array[Dictionary]:
	var c : Array[Dictionary] = []
	for item : Dictionary in _collection:
		c.append({
			DICT_KEY_ID : item[DICT_KEY_ID],
			DICT_KEY_WEIGHT : item[DICT_KEY_WEIGHT]
		})
	return c

# ------------------------------------------------------------------------------
# Override Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
func _DictHasKeyType(d : Dictionary, key : StringName, v_type : int) -> bool:
	if not key in d: return false
	return typeof(d[key]) == v_type

func _GetIDFromRandomAccum(rw : float) -> Variant:
	for item : Dictionary in _collection:
		if item[DICT_KEY_ACCUM] >= rw:
			return item[DICT_KEY_ID]
	return null

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
func size() -> int:
	return _collection.size()

func clear() -> void:
	_accum_weight = 0.0
	_collection.clear()

func get_accum_weight() -> float:
	return _accum_weight

func add_entry(entry : Variant, weight : float) -> void:
	if weight <= 0.0 or entry == null: return
	_collection.append({
		DICT_KEY_ID: entry,
		DICT_KEY_WEIGHT: weight,
		DICT_KEY_ACCUM: _accum_weight + weight
	})
	_accum_weight += weight

func get_random() -> Variant:
	return _GetIDFromRandomAccum(randf() * _accum_weight)

func get_from_rng(rng : RandomNumberGenerator) -> Variant:
	return _GetIDFromRandomAccum(rng.randf() * _accum_weight)

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------
