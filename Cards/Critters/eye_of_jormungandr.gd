extends CreatureCardDefinition

func _init() -> void:
	id = &"eye_of_jormungandr"
	card_name = "Eye of Jörmungandr"
	card_text = ""
	gate = CardGate.BasicGate(15)
	attack = 0
	endurance = 5
	sets = [&"critters"]
