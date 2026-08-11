extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_rogue"
	card_name = "Goblin Rogue"
	card_text = "Quick"
	gate = CardGate.new(CardGate.GateType.INTERVAL, 25, 25, 30)
	attack = 1
	endurance = 2
	sets = ["goblin_forces"]

func _build_abilities() -> Array[Ability]:
	return [CardKeywords.QUICK_ABILITY()]
