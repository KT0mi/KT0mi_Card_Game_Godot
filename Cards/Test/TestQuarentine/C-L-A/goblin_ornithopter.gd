extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_ornithopter"
	card_name = "Goblin Ornithopter"
	card_text = ""
	gate = CardGate.BasicGate(20)
	attack = 2
	endurance = 5
