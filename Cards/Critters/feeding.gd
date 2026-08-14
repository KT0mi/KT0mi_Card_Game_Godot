extends SpellCardDefinition

func _init() -> void:
	id = &"feeding"
	card_name = "Feeding"
	card_text = "Choose any 1 creature card in the arena, +1 Endurance"
	gate = CardGate.BasicGate(25)
	cast_type = CastType.INSTANT
	sets = [&"critters"]
	
func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	var candidates := GameState.all_cards_in_arena().duplicate()
	if candidates.is_empty(): return
	
	var target := await ChoiceManager.request_card(
		"Choose any 1 creature card in the arena:",
		candidates,
		card.owner,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.BUFF,
			card,
			card.owner
		)
	)
	
	GameActions.try_modify_endurance(target, StatModifer.delta(1, card))
