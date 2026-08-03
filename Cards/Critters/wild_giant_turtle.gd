extends CreatureCardDefinition

func _init() -> void:
	id = &"wild_giant_turtle"
	card_name = "Wild Giant Turtle"
	card_text = ""
	attack = 2
	gate = CardGate.BasicGate(19)
	endurance = 3
	sets = [&"critters"]
