extends SpellCardDefinition

func _init() -> void:
	id = &"coagulate_cross"
	card_name = "Coagulate: Cross"
	card_text = "Sacrifice 2 Blood Wall cards from your Arena: Deal 5 damage to your opponent."
	gate = CardGate.BasicGate(10)
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance]
	for c in card.owner.arena().duplicate():
		if c.get_id() == &"blood_wall":
			candidates.append(c)
	
	if candidates.is_empty() or candidates.size() < 2:
		print("coagulate_spear: resolve_effect: Skipped effect due to no valid candidates")
		return
	
	var response := await ChoiceManager.request(
		"Choose 2 Blood Wall from your Arena to sacrifice.",
		Events.EFFECT_TAG,
		candidates,
		card.owner,
		2,
		2
		)
	
	for s in response:
		if s == null:
			push_warning("coagulate_spear: resolve_effect: Wrong type for 'sacrifice' variable")
			return
		await GameActions.try_kill_card(s)
	
	
	await DamagePipeline.apply_damage(GameState.opponent_of(card.owner).get_player_card(), 5, card)
