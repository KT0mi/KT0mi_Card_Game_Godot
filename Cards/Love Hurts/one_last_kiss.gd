extends SpellCardDefinition

func _init() -> void:
	id = &"one_last_kiss"
	card_name = "One Last Kiss"
	card_text = "Discard 1 card: Return up to 5 'Bleeding Heart' cards to your SpellBook."
	gate = CardGate.None()
	cast_type = CastType.INSTANT
	

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance] = card.owner.hand.duplicate()
	if candidates.is_empty() or candidates == null:
		print("one_last_kiss: Effect Failed. Reason: No cards in hand")
		return
	
	
	
	
