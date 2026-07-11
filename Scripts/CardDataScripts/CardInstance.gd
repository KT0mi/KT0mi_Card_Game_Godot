class_name CardInstance extends RefCounted

var definition: CardDefinition
var owner: Player

var current_zone: Zone.Type = Zone.Type.DECK
var current_endurance: int = 0

var counters: Dictionary = {}
var flags: Dictionary = {}

var damage_modifiers: Array[Callable] = []

func _init(def: CardDefinition, p: Player) -> void:
	definition = def
	owner = p
	if def is CreatureCardDefinition:
		current_endurance = def.endurance

func is_creature() -> bool:
	return definition is CreatureCardDefinition
	
func is_spell() -> bool:
	return definition is SpellCardDefinition
