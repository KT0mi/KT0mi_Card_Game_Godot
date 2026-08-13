extends SpellCardDefinition

func _init() -> void:
	id = &"thetis_oversight"
	card_name = "Thetis' Oversight"
	card_text = "Give -1/-1 to all arena creatures."
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT
	sets = ["gods_judgement"]
	
func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	for c in GameState.all_cards_in_arena():
		if c.is_creature():
			GameActions.try_modify_attack(c, StatModifer.delta(-1, card))
			GameActions.try_modify_endurance(c, StatModifer.delta(-1, card))
