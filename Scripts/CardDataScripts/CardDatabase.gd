extends Node
##autoload

#scans game directory for CardDefinition scripts

const CARDS_ROOT := "res://Cards/"

var _definitions: Dictionary = {} # Stringname -> CardDefinition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_scan_dir(CARDS_ROOT)

func _scan_dir(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("CardDatabase: could not open %s" % path)
		return
		
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var full_path := path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_scan_dir(full_path)
		elif entry.ends_with(".gd"):
			_load_definition(full_path)
		entry = dir.get_next()
	dir.list_dir_end()
	
func _load_definition(script_path: String) -> void:
	var script: GDScript = load(script_path)
	var instance = script.new()
	if not (instance is CardDefinition):
		return  # stray .gd file in Cards/ that isn't a card -- ignore
 
	var def: CardDefinition = instance
	if def.id == &"":
		push_warning("CardDatabase: %s has no id set, skipping" % script_path)
		return
	if _definitions.has(def.id):
		push_warning("CardDatabase: duplicate card id '%s' (%s)" % [def.id, script_path])
 
	_definitions[def.id] = def
 
func get_definition(id: StringName) -> CardDefinition:
	if not _definitions.has(id):
		push_error("CardDatabase: unknown card id '%s'" % id)
		return null
	return _definitions[id]
 
func has_definition(id: StringName) -> bool:
	return _definitions.has(id)
