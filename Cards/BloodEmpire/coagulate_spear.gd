extends SpellCardDefinition

func _init() -> void:
	id = &"coagulate_spear"
	card_name = "Coagulate: Spear"
	card_text = "Sacrifice 1 Blood Wall from your Arena: Deal 2 damage to any card."
	gate = CardGate.BasicGate(15)
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance]
	for c in card.owner.arena().duplicate():
		if c.get_id() == &"blood_wall":
			candidates.append(c)
	
	if candidates.is_empty():
		print("coagulate_spear: resolve_effect: Skipped effect due to no valid candidates")
		return
	
	var sacrifice := await ChoiceManager.request_card(
		"Choose 1 Blood Wall from your Arena to sacrifice.",
		candidates,
		card.owner,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.SACRIFICE,
			card,
			card.owner
			)
		)
	
	await GameActions.try_kill_card(sacrifice)
	
	var target := await ChoiceManager.request_card(
		"Choose 1 card to deal 2 damage to.",
		GameState.all_cards_in_target_areas(),
		card.owner,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.DAMAGE,
			card,
			card.owner,
			2
			)
		)
	
	await DamagePipeline.apply_damage(target, 2, card)
