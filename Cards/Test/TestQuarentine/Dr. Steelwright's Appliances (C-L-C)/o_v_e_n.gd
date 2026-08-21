extends CreatureCardDefinition

func _init() -> void:
	id = &"o_v_e_n"
	card_name = "O.V.E.N: Orderly Prototype of Exothermic Nexus"
	card_text = "At the start of your Battle Phase: You can discard 1 card from your hand and deal 1 damage to yourself: Choose 1 creature card from the arena and kill it."
	is_special = true
	gate = CardGate.BasicGate(15)
	attack = 3
	endurance = 3
	sets = ["dr_steelwrights_appliances"]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.BATTLE_PHASE_START,
			_o_v_e_n_effect,
			func(c,e) -> bool: return e.player == c.owner
		)
	]

func _o_v_e_n_effect(card : CardInstance, event : PhaseEvent)-> void:
	var candidates := card.owner.hand
	if candidates.is_empty(): return
	
	var target_candidates := GameState.all_cards_in_arena()
	if target_candidates.is_empty(): return
	
	var try_discard := await ChoiceManager.request_cards(
		"Choose 1 card to discard or choose nothing:",
		candidates,
		card.owner,
		0,
		1,
		ChoiceContext.SACRIFICE_EFFECT(card)
	)
	
	if try_discard.is_empty():
		return
	var discard := try_discard[0]
	
	await ZoneManager.move_to(discard, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.DISCARD)
	await DamagePipeline.apply_damage(card.owner.get_player_card(), 1, card, DamageEvent.Reason.CARD_EFFECT)
	
	var target := await ChoiceManager.request_card(
		"Choose 1 card from the arena:",
		target_candidates,
		card.owner,
		ChoiceContext.KILL_EFFECT(card)
	)
	
	await GameActions.try_kill_card(target)
