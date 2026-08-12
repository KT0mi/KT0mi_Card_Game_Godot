extends SpellCardDefinition

func _init() -> void:
	id = &"sacrifice_ritual"
	card_name = "Sacrifice Ritual"
	card_text = "For each creature card in your arena: Sacrifice it and play 1 'Blood Wall' in it's place."
	gate = CardGate.BasicGate(25)
	cast_type = CastType.INSTANT
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	#Placeholder
	for c : CardInstance in card.owner.arena().duplicate():
		var l := c.lane
		if await GameActions.try_kill_card(c):
			await GameActions.try_summon_card(card.owner, &"blood_wall", Zone.Type.ARENA, l)
