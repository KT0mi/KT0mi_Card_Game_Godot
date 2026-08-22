extends Node
##Autoload

const SETS_ROOT := "res://Sets/"
var _sets: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_scan_dir(SETS_ROOT)

func _scan_dir(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("CardSetDatabase: could not open %s" % path)
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.ends_with(".tres"):
			_load_set(path.path_join(entry))
		elif entry.ends_with(".tres.remap"):
			# Exported builds replace foo.tres with foo.tres.remap + a
			# binary resource. load() still resolves the original ".tres"
			# path correctly -- Godot follows the remap internally.
			_load_set(path.path_join(entry).trim_suffix(".remap"))
		entry = dir.get_next()
	dir.list_dir_end()

func _load_set(res_path: String) -> void:
	var res: Resource = load(res_path)
	if not (res is CardSet):
		return
	if res.id == &"":
		push_warning("CardSetDatabase: %s has no id set, skipping" % res_path)
		return
	_sets[res.id] = res
	
func get_set(id: StringName) -> CardSet:
	if not _sets.has(id):
		push_error("CardSetDatabase: unknown set id '%s'" % id)
		return null
	return _sets[id]
	
func has_set(id: StringName) -> bool:
	return _sets.has(id)
	
func get_all_sets() -> Array[CardSet]:
	var result: Array[CardSet] = []
	result.append_array(_sets.values())
	return result
