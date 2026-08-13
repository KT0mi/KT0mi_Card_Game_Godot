extends SpellCardDefinition

func _init() -> void:
	id = &"ostracize"
	card_name = "Ostracize"
	card_text = "Choose 1 card from the arena: Return it to it's owner's hand."
	gate = CardGate.BasicGate(25)
	cast_type = CastType.INSTANT
	sets = ["gods_judgement"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance] = GameState.all_cards_in_arena().duplicate()
	
	if candidates.is_empty():
		push_warning("ostracize: Effect not resolved. Reason: No valid candidates")
		return
	
	var tA := await ChoiceManager.request(
		"Choose 1 card from the arena:",
		Events.EFFECT_TAG,
		candidates,
		card.owner
	)
	
	var target :CardInstance= tA[0]
	if target == null:
		push_warning("ostracize: Effect not resolved. Reason: No valid target")
		return
	
	target.clear_all_modifiers()
	target.reset_stats()
	ZoneManager.move_to(target, Zone.Type.HAND, ZoneChangeEvent.Reason.RETURN)
