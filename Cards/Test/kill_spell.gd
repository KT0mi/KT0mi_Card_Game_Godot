extends SpellCardDefinition

func _init() -> void:
	id = &"kill_spell"
	card_name = "Kill All Spell"
	card_text = ""
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"test_set"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	var targets : Array[CardInstance] = GameState.opponent_of(card.owner).arena.duplicate()
	for c in targets:
		await GameActions.try_kill_card(c)
