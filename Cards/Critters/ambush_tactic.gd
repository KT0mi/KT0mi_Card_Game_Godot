extends SpellCardDefinition

func _init() -> void:
	id = &"ambush_tactic"
	card_name = "Ambush Tactic"
	card_text = "Choose any 1 damageable card, then choose 1 creature from your arena that can attack to attack it."
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT
	sets = [&"critters"]
	
func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var target := await ChoiceManager.request_card(
		"Choose any 1 damageable card:",
		GameState.all_cards_in_target_areas(),
		card.owner,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.ATTACK_TARGET,
			card,
			card.owner
		)
	)
	
	var candidates := card.owner.arena().duplicate()
	if candidates.is_empty(): return
	
	var attacker := await ChoiceManager.request_card(
		"Choose any 1 card from your arena:",
		candidates,
		card.owner,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.ATTACK_ATTACKER,
			card,
			card.owner
		)
	)
	
	GameActions.try_attack(attacker, target)
