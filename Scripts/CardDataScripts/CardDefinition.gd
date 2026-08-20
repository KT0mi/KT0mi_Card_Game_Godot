class_name CardDefinition extends Resource

@export var id: StringName
@export var card_name: String
@export var card_text: String
@export var is_special: bool = false
@export var gate: CardGate
@export var sets: Array[StringName] = []
@export var art: Texture2D

##Tags for matching this card from other card's effects
##This both means that any card can have more than one tagged damage
##And that many cards can opt into the same damage tag
##(E.G. If two cards want to deal "fire damage" or something"
@export var damage_tags: Array[StringName] = []

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
	
func get_primary_set() -> CardSet:
	return CardSetDatabase.get_set(sets[0]) if not sets.is_empty() else null
 
func has_keyword(keyword: StringName) -> bool:
	for a in get_abilities():
		if keyword in a.keywords:
			return true
	return false

func _build_abilities() -> Array[Ability]:
	return []


var _continuous_effects_cache: Array[ContinuousEffect] = []
var _continuous_effects_built: bool = false

## Same caching rationale as get_abilities(): a ContinuousEffect's
## Callables close over (source, candidate) / (value) passed in at query
## time, never over per-instance state at construction time, so building
## this once per definition is safe. Subclasses override
## _build_continuous_effects(), not this.
func get_continuous_effects() -> Array[ContinuousEffect]:
	if not _continuous_effects_built:
		_continuous_effects_cache = _build_continuous_effects()
		_continuous_effects_built = true
	return _continuous_effects_cache
 
func _build_continuous_effects() -> Array[ContinuousEffect]:
	return []
