extends SpellCardDefinition

func _init() -> void:
	id = &"test_spell"
	card_name = "Test Spell"
	card_text = ""
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"test_set"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	print("%s resolved Test Spell" % card.owner.player_name)
