class_name CardDefinition extends Resource

@export var id: StringName
@export var card_name: String
@export var card_text: String
@export var is_special: bool = false
@export var sets: Array[StringName] = []
@export var art: Texture2D

var _abilities_cache: Array[Ability] = []
var _abilities_built: bool = false
 
## Every copy of this card shares the exact same ability list -- the
## Callables close over (card, event) passed in at call time, never over
## instance-specific data at construction time -- so building this once
## per definition (not once per call, not once per instance) is safe and
## removes the main real overhead in a large game with many copies in
## play. Subclasses override _build_abilities(), not this.
func get_abilities() -> Array[Ability]:
	if not _abilities_built:
		_abilities_cache = _build_abilities()
		_abilities_built = true
	return _abilities_cache
 
func _build_abilities() -> Array[Ability]:
	return []
