extends CreatureCardDefinition

func _init() -> void:
	id = &"stag"
	card_name = "Stag"
	gate = CardGate.BasicGate(25)
	attack = 3
	endurance = 3
	sets = ["test_set"]
