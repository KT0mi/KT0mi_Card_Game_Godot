extends CreatureCardDefinition

func _init() -> void:
	id = &"blood_wall"
	card_name = "Blood Wall"
	card_text = ""
	attack = 0
	endurance = 3
	gate = CardGate.None()
	sets = [&"blood_empire"]
