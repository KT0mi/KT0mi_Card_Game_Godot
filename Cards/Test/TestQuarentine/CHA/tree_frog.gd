extends CreatureCardDefinition

func _init() -> void:
	id = &"tree_frog"
	card_name = "Tree Frog"
	card_text = ""
	gate = CardGate.BasicGate(20)
	attack = 2
	endurance = 6
	sets = ["pantagruel_islet"]
	
