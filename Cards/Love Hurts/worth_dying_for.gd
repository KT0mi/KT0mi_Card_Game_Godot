extends SpellCardDefinition

func _init() -> void:
	id = &"worth_dying_for"
	card_name = "Worth Dying For"
	card_text = "Sacrifice 1 creature from your arena: Add 3 'Bleeding Heart' cards to your Spellbook"
	gate = CardGate.BasicGate(25)
	cast_type = CastType.INSTANT
	sets = ["love_hurts"]
	

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates := card.owner.arena().duplicate()
	if candidates.is_empty(): return
	
	var sacrifice := await ChoiceManager.request_card(
		"Choose 1 creature from your arena:",
		candidates,
		card.owner,
		ChoiceContext.SACRIFICE_EFFECT(card)
	)
	
	await GameActions.try_kill_card(sacrifice)
	
	for i in range(3):
		GameActions.try_summon_card(card.owner, CardKeywords.BLEEDING_HEART, Zone.Type.SPELLBOOK)
