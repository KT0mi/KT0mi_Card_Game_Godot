extends SpellCardDefinition

func _init() -> void:
	id = &"sacrifice_ritual"
	card_name = "Sacrifice Ritual"
	card_text = "For each creature card in your arena: Sacrifice it and play 1 'Blood Wall' in it's place."
	gate = CardGate.BasicGate(25)
	cast_type = CastType.INSTANT

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	#TODO
	#Placeholder
	for c in card.owner.arena.duplicate():
		if await GameActions.try_kill_card(c):
			var bd := CardFactory.create_instance(&"blood_wall", card.owner)
			ZoneManager.move_to(bd, Zone.Type.ARENA, ZoneChangeEvent.Reason.SUMMON)
