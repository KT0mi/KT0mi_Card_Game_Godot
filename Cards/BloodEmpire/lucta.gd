extends SpellCardDefinition

func _init() -> void:
	id = &"lucta"
	card_name = "Lucta"
	card_text = "Sacrifice 1 health and deal 2 damage to opponent."
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	await DamagePipeline.apply_damage(card.owner.player_zone[0], 1, card)
	await DamagePipeline.apply_damage(GameState.opponent_of(card.owner).player_zone[0], 2, card)
