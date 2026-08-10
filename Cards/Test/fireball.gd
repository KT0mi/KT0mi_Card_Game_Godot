extends SpellCardDefinition

func _init() -> void:
	id = &"fireball"
	card_name = "Fireball"
	card_text = "Deal 1 damage to every card in your opponents arena"
	gate = CardGate.BasicGate(20)
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"test_set"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	for c in GameState.opponent_of(card.owner).arena():
		DamagePipeline.apply_damage(c, 1, card)
