extends SpellCardDefinition

func _init() -> void:
	id = &"coagulate_sword"
	card_name = "Coagulate: Sword"
	card_text = "Sacrifice 1 Blood Wall from your Arena: Deal 4 damage to any card of your opponent's arena."
	gate = CardGate.BasicGate(15)
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance]
	for c in card.owner.arena().duplicate():
		if c.get_id() == &"blood_wall":
			candidates.append(c)
	
	if candidates.is_empty():
		print("coagulate_sword: resolve_effect: Skipped effect due to no valid candidates")
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
	
	var candidatesB := GameState.opponent_of(card.owner).arena().duplicate()
	if candidatesB.is_empty(): return
	
	var target := await ChoiceManager.request_card(
		"Choose 1 card to deal 4 damage to.",
		candidatesB,
		card.owner,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.DAMAGE,
			card,
			card.owner,
			4
			)
		)
		
	await DamagePipeline.apply_damage(target, 4, card)
