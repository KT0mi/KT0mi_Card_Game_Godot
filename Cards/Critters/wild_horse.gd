extends CreatureCardDefinition

func _init() -> void:
	id = &"wild_horse"
	card_name = "Wild Horse"
	card_text = ""
	gate = CardGate.BasicGate(20)
	attack = 3
	endurance = 4
	sets = [&"critters"]
