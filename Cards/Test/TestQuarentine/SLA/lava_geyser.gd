extends SpellCardDefinition

func _init() -> void:
	id = &"lava_geyser"
	card_name = "Lava Geyser"
	card_text = "Deal 3 damage to the opponent and 2 to you"
	gate = CardGate.BasicGate(25)
	cast_type = CastType.INSTANT
	sets = ["fiery_tradition"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	await DamagePipeline.apply_damage(
		GameState.opponent_of(card.owner).get_player_card(),
		CheckSystem.effect_damage_of(card, 3),
		card
	)
	await DamagePipeline.apply_damage(
		GameState.opponent_of(card.owner).get_player_card(),
		CheckSystem.effect_damage_of(card, 2),
		card
	)
