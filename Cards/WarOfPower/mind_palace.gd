extends SpellCardDefinition

func _init() -> void:
	id = &"mind_palace"
	card_name = "Mind Palace"
	card_text = "After 2 turns of play, draw 2 cards on the start of the play phase."
	cast_type = SpellCardDefinition.CastType.PERSISTENT
	sets = [&"war_of_power"]
	
func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	card.counters.set("check", 2)
	
func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.PLAY_PHASE_START, 
	func(card, event)->void:
		GameActions.draw_cards(card.owner, 2)
		ZoneManager.move_to(card, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.DEATH)
	,
	func(card, event)->bool:
		return card.counters["check"] <= 0
	),
		Ability.new(Events.START_PHASE_START, 
	func(card, event)->void:
		GameActions.draw_cards(card.owner, 2)
	,
	func(card, event)->bool:
		return TurnController.current_player == card.owner
	)]
