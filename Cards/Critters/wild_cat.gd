extends CreatureCardDefinition

func _init() -> void:
	id = &"wild_cat"
	card_name = "Wild Cat"
	card_text = "Quick"
	gate = CardGate.None()
	attack = 1
	endurance = 1
	sets = [&"critters"]

func _build_abilities() -> Array[Ability]:
	return [CardKeywords.QUICK_ABILITY()]
