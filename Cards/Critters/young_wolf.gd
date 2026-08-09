extends CreatureCardDefinition

func _init() -> void:
	id = &"young_wolf"
	card_name = "Young Wolf"
	card_text = ""
	attack = 2
	gate = CardGate.BasicGate(30)
	endurance = 2
	sets = [&"critters"]
