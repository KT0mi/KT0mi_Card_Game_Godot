extends CreatureCardDefinition

func _init() -> void:
	id = &"test_enemy_card"
	card_name = "Opponent"
	card_text = ""
	attack = 1
	endurance = 30
	sets = [&"test_set"]
