extends SpellCardDefinition

func _init() -> void:
	id = &"magma_burst"
	card_name = "Magma Burst"
	card_text = "Choose any card in play: If it is a player card deal 1 damage, else deal 2 damage."
	gate = CardGate.None()
	cast_type = CastType.INSTANT
	sets = ["eruption_attack"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var target := await ChoiceManager.request_card(
		"Choose any card in play:",
		GameState.all_cards_in_target_areas(),
		card.owner,
		ChoiceContext.DAMAGE_EFFECT(card, 1)
	)
	
	if target.current_zone == Zone.Type.PLAYER:
		DamagePipeline.apply_damage(target, 1, card)
	else: 
		DamagePipeline.apply_damage(target, 2, card)
	
