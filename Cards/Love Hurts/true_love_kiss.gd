extends SpellCardDefinition

func _init() -> void:
	id = &"true_love_kiss"
	card_name = "True Love Kiss"
	card_text = "Deal 1 damage to opponent. Add 1 'Bleeding Heart' to your Spellbook."
	gate = CardGate.None()
	cast_type = CastType.INSTANT
	sets = ["love_hurts"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	DamagePipeline.apply_damage(GameState.opponent_of(card.owner).get_player_card(), 1, card)
	GameActions.try_summon_card(card.owner, CardKeywords.BLEEDING_HEART, Zone.Type.SPELLBOOK)
