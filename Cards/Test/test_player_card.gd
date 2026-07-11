extends CreatureCardDefinition

func _init() -> void:
	id = &"test_player_card"
	card_name = "Player"
	card_text = ""
	attack = 0
	endurance = 20
	sets = [&"core"]
