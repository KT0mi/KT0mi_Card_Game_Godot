extends SpellCardDefinition

func _init() -> void:
	id = &"one_last_kiss"
	card_name = "One Last Kiss"
	card_text = "Discard 1 card: Return up to 5 'Bleeding Heart' cards to your SpellBook."
	gate = CardGate.BasicGate(25)
	cast_type = CastType.INSTANT
	sets = ["love_hurts"]
	

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance] = card.owner.hand.duplicate()
	candidates.erase(card)
	if candidates.is_empty() or candidates == null:
		print("one_last_kiss: Effect Failed. Reason: No cards in hand")
		return
	
	var discard := await ChoiceManager.request_card(
		"Choose 1 card to discard:",
		candidates,
		card.owner,
		ChoiceContext.DISCARD_EFFECT(card)
	)
	
	ZoneManager.move_to(discard, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.DISCARD)
	
	var i := 0
	for c in card.owner.graveyard:
		if i >= 5: return
		if c.get_id() == CardKeywords.BLEEDING_HEART:
			ZoneManager.move_to(c, Zone.Type.SPELLBOOK, ZoneChangeEvent.Reason.RETURN)
			i += 1
