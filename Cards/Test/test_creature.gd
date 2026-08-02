extends CreatureCardDefinition

func _init() -> void:
	id = &"test_creature"
	card_name = "Test Creature"
	card_text = ""
	gate = CardGate.BasicGate(10)
	attack = 5
	endurance = 5
	sets = [&"test_set"]
