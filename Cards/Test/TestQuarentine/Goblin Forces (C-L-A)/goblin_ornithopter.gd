extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_ornithopter"
	card_name = "Goblin Ornithopter"
	card_text = ""
	gate = CardGate.BasicGate(25)
	attack = 2
	endurance = 5
	sets = ["goblin_forces"]
