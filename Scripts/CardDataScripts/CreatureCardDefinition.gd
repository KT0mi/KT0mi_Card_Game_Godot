class_name CreatureCardDefinition extends CardDefinition

@export var attack: int = 0
@export var endurance: int = 1

#Method that is asked when gathering candidates for battle
func is_battle_ready(_card: CardInstance):
	return true
