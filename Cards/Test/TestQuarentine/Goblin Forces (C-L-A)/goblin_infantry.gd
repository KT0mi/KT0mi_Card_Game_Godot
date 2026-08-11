extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_infantry"
	card_name = "Goblin Infantry"
	card_text = ""
	gate = CardGate.None()
	attack = 2
	endurance = 2
	sets = ["goblin_forces"]
