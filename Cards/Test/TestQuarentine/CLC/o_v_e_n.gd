extends CreatureCardDefinition

func _init() -> void:
	id = &"o_v_e_n"
	card_name = "O.V.E.N: Orderly Prototype of Exothermic Nexus"
	card_text = "At the start of your Battle Phase: Discard 1 card from your hand and deal 1 damage to yourself: Choose 1 creature card from the arena and kill it."
	is_special = true
	gate = CardGate.BasicGate(20)
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
	
	var discard := await ChoiceManager.request_card(
		"Choose 1 card to discard:",
		candidates,
		card.owner,
		ChoiceContext.SACRIFICE_EFFECT(card)
	)
	
	ZoneManager.move_to(discard, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.DISCARD)
	DamagePipeline.apply_damage(card.owner.get_player_card(), 1, card, DamageEvent.Reason.CARD_EFFECT)
	
	var target := await ChoiceManager.request_card(
		"Choose 1 card from the arena:",
		target_candidates,
		card.owner,
		ChoiceContext.KILL_EFFECT(card)
	)
	
	GameActions.try_kill_card(target)
