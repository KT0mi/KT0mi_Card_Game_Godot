extends SpellCardDefinition

func _init() -> void:
	id = &"test_spell"
	card_name = "Test Spell"
	card_text = "Adds +1 Endurance to all your cards in the arena"
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"test_set"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	for c in card.owner.arena:
		GameActions.try_modify_endurance(c, 
		StatModifer.new(func(endurance) -> int: return endurance + 1,
		card,
		"+1 Endurance")
		)
