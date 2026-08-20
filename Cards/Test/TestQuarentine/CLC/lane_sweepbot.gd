extends CreatureCardDefinition

func _init() -> void:
	id = &"lane_sweepbot"
	card_name = "Lane Sweep-bot"
	card_text = "Block"
	gate = CardGate.None()
	attack = 1
	endurance = 2
	sets = ["dr_steelwrights_appliances"]
	
func _build_abilities() -> Array[Ability]:
	return [CardKeywords.BLOCK_ABILITY()]
