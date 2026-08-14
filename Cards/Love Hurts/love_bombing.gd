extends SpellCardDefinition

func _init() -> void:
	id = &"love_bombing"
	card_name = "Love Bombing"
	card_text = "Choose X 'Bleeding Heart' cards, up to 5: Spend the chosen cards and deal 1 Damage to a random opponent's card X times."
	gate = CardGate.BasicGate(25)
	cast_type = CastType.INSTANT
	sets = ["love_hurts"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance]
	for c in card.owner.spellbook:
		if c.get_id() == CardKeywords.BLEEDING_HEART:
			candidates.append(c)
	
	if candidates.is_empty():
		print("love_bombing: Effect failed. Reason: No valid candidates")
		return
		
	var sacrifices := await ChoiceManager.request_cards(
		"Choose 'Bleeding Hearts' cards:",
		candidates,
		card.owner,
		0,5,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.SACRIFICE,
			card,
			card.owner
		)
	)
	
	if sacrifices.is_empty():
		print("love_bombing: Effect failed. Reason: No chosen cards")
		return
	
	for c in sacrifices:
		await ZoneManager.move_to(c, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.MANUAL)
		
		var target : CardInstance = GameState.opponent_of(card.owner).all_cards_in_target_areas().pick_random()
		await DamagePipeline.apply_damage(target, 1, card)
