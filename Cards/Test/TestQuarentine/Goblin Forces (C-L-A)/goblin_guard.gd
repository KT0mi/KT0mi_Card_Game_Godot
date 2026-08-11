extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_guard"
	card_name = "Goblin Guard"
	card_text = ""
	gate = CardGate.BasicGate(28)
	attack = 3
	endurance = 2
	sets = ["goblin_forces"]
