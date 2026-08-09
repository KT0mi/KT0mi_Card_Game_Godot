extends CreatureCardDefinition

func _init() -> void:
	id = &"body_of_jormungandr"
	card_name = "Body of Jörmungandr"
	card_text = "'The infinite scales of the world serpent.'"
	gate = CardGate.BasicGate(15)
	attack = 0
	endurance = 5
	sets = [&"critters"]
