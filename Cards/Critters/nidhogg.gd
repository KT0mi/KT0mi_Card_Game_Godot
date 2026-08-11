extends CreatureCardDefinition

func _init() -> void:
	id = &"nidhogg"
	card_name = "Nidhogg: Dragon of the World Tree Roots"
	card_text = ""
	gate = CardGate.BasicGate(10)
	attack = 7
	endurance = 7
	is_special = true
	sets = [&"critters"]
