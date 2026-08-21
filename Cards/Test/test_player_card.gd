extends CreatureCardDefinition

func _init() -> void:
	id = &"test_player_card"
	card_name = "Player"
	card_text = ""
	attack = 1
	endurance = 15
	sets = [&"test_set"]
