extends SpellCardDefinition

func _init() -> void:
	id = &"hand_the_fire"
	card_name = "Hand the Fire"
	card_text = "Your opponent draws 1 card: Deal 2 damage to their player card."
	gate = CardGate.None()
	cast_type = CastType.INSTANT
	sets = ["fiery_tradition"]
	

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	await GameActions.draw_cards(GameState.opponent_of(card.owner), 1, DrawCardEvent.Reason.EFFECT)
	
	await DamagePipeline.apply_damage(
		GameState.opponent_of(card.owner).get_player_card(),
		CheckSystem.effect_damage_of(card, 2),
		card
	)
	
