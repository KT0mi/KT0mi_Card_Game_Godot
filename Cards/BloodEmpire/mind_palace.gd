extends SpellCardDefinition

func _init() -> void:
	id = &"mind_palace"
	card_name = "Mind Palace"
	card_text = "After 2 turns of play, draw 1 card on the start of the play phase."
	cast_type = SpellCardDefinition.CastType.PERSISTENT
	sets = [&"blood_empire"]
	
func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	card.counters["check"] = 2
	
func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.PLAY_PHASE_START, 
	func(card, event)->void:
		GameActions.draw_cards(card.owner, 1)
		ZoneManager.move_to(card, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.DEATH)
	,
	func(card, event)->bool:
		return card.counters["check"] <= 0
	),
		Ability.new(Events.START_PHASE_START, 
	func(card, event)->void:
		card.counters["check"] -= 1
	)]
