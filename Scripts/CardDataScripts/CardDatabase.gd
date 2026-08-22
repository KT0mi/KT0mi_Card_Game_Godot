extends Node
##autoload

#scans game directory for CardDefinition scripts

const CARDS_ROOT := "res://Cards/"
const CARD_SPRITES_ROOT := "res://Assets/Images/Cards/Sprites/"

var _definitions: Dictionary = {} # Stringname -> CardDefinition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("CardDatabase: DIAG starting scan of %s" % CARDS_ROOT)
	_scan_dir(CARDS_ROOT)
	print("CardDatabase: DIAG scan complete, %d definitions registered" % _definitions.size())

func _scan_dir(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("CardDatabase: could not open %s" % path)
		print("CardDatabase: DIAG DirAccess.open error code: %s" % DirAccess.get_open_error())
		return
		
	dir.list_dir_begin()
	var entry := dir.get_next()
	var found_any := false
	while entry != "":
		found_any = true
		print("CardDatabase: DIAG found entry '%s' in %s (is_dir=%s)" % [entry, path, dir.current_is_dir()])
		var full_path := path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_scan_dir(full_path)
		elif entry.ends_with(".gd"):
			_load_definition(full_path)
		elif entry.ends_with(".gd.remap"):
			# Exported builds replace foo.gd with foo.gd.remap + foo.gdc.
			# load() still resolves the original ".gd" path correctly --
			# Godot follows the remap internally -- so strip ".remap" and
			# load that, never the ".gdc" directly.
			_load_definition(full_path.trim_suffix(".remap"))
		entry = dir.get_next()
	dir.list_dir_end()
	if not found_any:
		print("CardDatabase: DIAG %s enumerated ZERO entries" % path)
	
func _load_definition(script_path: String) -> void:
	var script: GDScript = load(script_path)
	if script == null:
		print("CardDatabase: DIAG load() returned null for %s" % script_path)
		return
	var instance = script.new()
	if instance == null:
		print("CardDatabase: DIAG script.new() returned null for %s" % script_path)
		return
	if not (instance is CardDefinition):
		print("CardDatabase: DIAG %s instance is NOT CardDefinition (got %s)" % [script_path, instance.get_class()])
		return  # stray .gd file in Cards/ that isn't a card -- ignore
 
	var def: CardDefinition = instance
	if def.id == &"":
		push_warning("CardDatabase: %s has no id set, skipping" % script_path)
		return
	if _definitions.has(def.id):
		push_warning("CardDatabase: duplicate card id '%s' (%s)" % [def.id, script_path])
 	
	_load_card_sprite(def)
	_definitions[def.id] = def
	print("CardDatabase: DIAG registered '%s' from %s" % [def.id, script_path])

func _load_card_sprite(def: CardDefinition) -> void:
	var path := CARD_SPRITES_ROOT + def.id + ".png"
	if not FileAccess.file_exists(path):
		push_warning("CardDatabase: could not find %s" % path)
		def.art = preload("res://Assets/Images/Cards/Sprites/placeholder.png")
		return
	def.art = load(path)

func get_definitions_grouped_by_set() -> Dictionary:
	var result: Dictionary = {}  # StringName -> Array[CardDefinition]
	for def in get_all_definitions():
		var set_id : StringName = def.sets[0] if not def.sets.is_empty() else &"test_set"
		if not result.has(set_id):
			result[set_id] = []
		result[set_id].append(def)
	for set_id in result:
		result[set_id].sort_custom(func(a, b): return a.card_name < b.card_name)
	return result

func get_all_definitions() -> Array[CardDefinition]:
	var result: Array[CardDefinition] = []
	result.append_array(_definitions.values())
	return result

func get_definition(id: StringName) -> CardDefinition:
	if not _definitions.has(id):
		push_error("CardDatabase: unknown card id '%s'" % id)
		return null
	return _definitions[id]
 
func has_definition(id: StringName) -> bool:
	return _definitions.has(id)
