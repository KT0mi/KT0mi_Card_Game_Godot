extends SpellCardDefinition

func _init() -> void:
	id = &"lucta"
	card_name = "Lucta"
	card_text = "Choose 1 of your arena cards: Sacrifice it and deal 2 damage to opponent."
	cast_type = SpellCardDefinition.CastType.INSTANT
	gate = CardGate.None()
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	var candidates := card.owner.arena().duplicate()
	if candidates.is_empty(): return
	
	var sacrifice := await ChoiceManager.request_card(
		"Choose 1 of your arena cards",
		candidates,
		card.owner,
		ChoiceContext.new(
				ChoiceContext.Origin.CARD_EFFECT,
				ChoiceContext.Intent.SACRIFICE,
				card,
				card.owner)
	)
	
	await GameActions.try_kill_card(sacrifice)
	await DamagePipeline.apply_damage(GameState.opponent_of(card.owner).get_player_card(), 2, card)
