extends CreatureCardDefinition

func _init() -> void:
	id = &"basic_wolf"
	card_name = "Basic Wolf"
	card_text = ""
	attack = 2
	gate = CardGate.BasicGate(20)
	endurance = 2
	sets = [&"test_set"]
