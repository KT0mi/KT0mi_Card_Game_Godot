extends SpellCardDefinition

func _init() -> void:
	id = &"love_pact"
	card_name = "Love Pact"
	card_text = "Both players recieve 2 damage and draw 2 cards"
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT
	sets = ["love_hurts"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	for p in GameState.players():
		DamagePipeline.apply_damage(p.get_player_card(), 2, card)
		GameActions.draw_cards(p, 2, DrawCardEvent.Reason.EFFECT)
