extends CreatureCardDefinition

func _init() -> void:
	id = &"wild_cat"
	card_name = "Wild Cat"
	card_text = "Quick"
	gate = CardGate.BasicGate(20)
	attack = 1
	endurance = 1
	is_dazed = false
	
