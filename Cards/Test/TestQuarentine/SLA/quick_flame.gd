extends SpellCardDefinition

func _init() -> void:
	id = &"quick_flame"
	card_name = "Quick Flame"
	card_text = "Deal 3 damage to the opponent"
	gate = CardGate.new(CardGate.GateType.INTERVAL, 24, 24,25)
	cast_type = CastType.INSTANT
	sets = ["fiery_tradition"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	await DamagePipeline.apply_damage(
		GameState.opponent_of(card.owner).get_player_card(),
		CheckSystem.effect_damage_of(card, 3),
		card
	)
