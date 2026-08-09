extends CreatureCardDefinition

func _init() -> void:
	id = &"minor_blood_deacon"
	card_name = "Minor Blood Deacon"
	card_text = ""
	attack = 2
	endurance = 2
	gate = CardGate.None()
	sets = [&"blood_empire"]
