extends CreatureCardDefinition

func _init() -> void:
	id = &"taunt_creature"
	card_name = "Taunt Creature"
	card_text = "Taunt"
	attack = 1
	endurance = 3
	gate = CardGate.None()
	sets = [&"test_set"]
	
func _build_abilities() -> Array[Ability]:
	return [CardKeywords.TAUNT_ABILITY()]
