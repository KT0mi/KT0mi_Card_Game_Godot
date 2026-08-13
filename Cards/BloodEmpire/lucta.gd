extends SpellCardDefinition

func _init() -> void:
	id = &"lucta"
	card_name = "Lucta"
	card_text = "Choose 1 of your arena cards: Sacrifice it and deal 2 damage to opponent."
	cast_type = SpellCardDefinition.CastType.INSTANT
	gate = CardGate.None()
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	#TODO
	var sA : Array = await ChoiceManager.request(
		"Choose 1 of your arena cards",
		
		card.owner.arena().duplicate(),
		card.owner,
	)
	if sA.is_empty(): return
	
	var sacrifice : CardInstance = sA[0]
	if sacrifice == null:
		return
	
	await GameActions.try_kill_card(sacrifice)
	await DamagePipeline.apply_damage(GameState.opponent_of(card.owner).get_player_card(), 2, card)
