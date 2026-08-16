extends CreatureCardDefinition

func _init() -> void:
	id = &"target_bot"
	card_name = "Target-Bot"
	card_text = "Taunt"
	gate = CardGate.BasicGate(30)
	attack = 0
	endurance = 3
	sets = ["dr_tetheus_appliances"]
	
func _build_abilities() -> Array[Ability]:
	return [CardKeywords.TAUNT_ABILITY()]
