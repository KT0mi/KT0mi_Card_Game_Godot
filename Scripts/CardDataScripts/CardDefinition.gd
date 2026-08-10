class_name CardDefinition extends Resource

@export var id: StringName
@export var card_name: String
@export var card_text: String
@export var is_special: bool = false
@export var gate: CardGate
@export var sets: Array[StringName] = []
@export var art: Texture2D

#Overrideable on specific card definitions to inject dynamic instance state into
#the displayed text. Defaults to card_text so that any card that doesn't have.
#Dynamic text isn't affected and doesn't even have to touch this
func get_display_text(_instance: CardInstance) -> String:
	return card_text

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
 
func has_keyword(keyword: StringName) -> bool:
	for a in get_abilities():
		if keyword in a.keywords:
			return true
	return false

func _build_abilities() -> Array[Ability]:
	return []
