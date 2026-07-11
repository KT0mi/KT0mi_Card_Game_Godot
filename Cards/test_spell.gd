extends SpellCardDefinition

func _init() -> void:
	id = &"test_spell"
	card_name = "Test Spell"
	card_text = ""
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"test_set"]

func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.CARD_PLAYED,
	func(card, event): print("%s resolved Test Bold" % card.owner.player_name),
	func(card, event): return event.card == card)]
