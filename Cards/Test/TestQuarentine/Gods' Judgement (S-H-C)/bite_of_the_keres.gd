extends SpellCardDefinition

func _init() -> void:
	id = &"bite_of_the_keres"
	card_name = "Bite of the Keres"
	card_text = "Choose 1 damaged card from the arena: Kill it."
	gate = CardGate.BasicGate(15)
	cast_type = CastType.INSTANT
	sets = ["gods_judgement"]
	
func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance]
	for c in GameState.all_cards_in_arena():
		if c.get_endurance() < c.definition.endurance:
			candidates.append(c)
	
	if candidates.is_empty():
		push_warning("bite_of_the_keres: Effect not resolved. Reason: No valid candidates")
		return
	
	var tA := await ChoiceManager.request(
		"Choose 1 damaged card from the arena:",
		Events.EFFECT_TAG,
		candidates,
		card.owner
	)
	
	var target :CardInstance= tA[0]
	if target == null:
		push_warning("bite_of_the_keres: Effect not resolved. Reason: No valid target")
		return
	
	GameActions.try_kill_card(target)
