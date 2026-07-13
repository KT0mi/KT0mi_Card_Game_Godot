extends SpellCardDefinition

func _init() -> void:
	id = &"coagulate_spear"
	card_name = "Coagulate Spear"
	card_text = "Sacrifice 1 Blood Wall from your Arena: Deal 2 damage to any card."
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance]
	for c in card.owner.arena.duplicate():
		if c.get_id() == &"blood_wall":
			candidates.append(c)
	
	if candidates.is_empty():
		print("coagulate_spear: resolve_effect: Skipped effect due to no valid candidates")
		return
	
	var response := await ChoiceManager.request(
		"Choose 1 Blood Wall from your Arena to sacrifice.",
		candidates,
		1,
		1,
		card.owner)
	
	var sacrifice := response[0] as CardInstance
	if sacrifice == null:
		push_warning("coagulate_spear: resolve_effect: Wrong type for 'sacrifice' variable")
		return
	
	await GameActions.try_kill_card(sacrifice)
	
	var responseB := await ChoiceManager.request(
		"Choose 1 card to deal 2 damage to.",
		GameState.all_cards_in_target_areas(),
		1,
		1,
		card.owner)
		
	var target := responseB[0] as CardInstance
	if target == null:
		push_warning("coagulate_spear: resolve_effect: Wrong type for 'sacrifice' variable")
		return
	
	DamagePipeline.apply_damage(target, 2)
