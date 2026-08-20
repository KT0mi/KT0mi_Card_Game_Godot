extends SpellCardDefinition

func _init() -> void:
	id = &"oil_change"
	card_name = "Oil Change"
	card_text = "Choose 1 arena card: It gets +1/+3 and becomes Dazed."
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT
	sets = ["dr_steelwrights_appliances"]
	

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates := GameState.all_cards_in_arena()
	if candidates.is_empty(): return
	
	var target := await ChoiceManager.request_card(
		"Choose 1 card from the arena:",
		candidates,
		card.owner,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.BUFF,
			card,
			card.owner
		)
	)
	
	GameActions.try_add_attack_modifier(target, StatModifer.delta(1, card))
	GameActions.try_add_endurance_modifier(target, StatModifer.delta(3, card))
	target.set_flag(CardKeywords.DAZED, true)
