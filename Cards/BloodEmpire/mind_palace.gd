extends SpellCardDefinition

func _init() -> void:
	id = &"mind_palace"
	card_name = "Mind Palace"
	card_text = "After 2 turns of play, draw 1 card on the start of the play phase."
	gate = CardGate.None()
	cast_type = SpellCardDefinition.CastType.PERSISTENT
	sets = [&"blood_empire"]

const TURNS_KEY := &"turns_remaining"

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	card.set_counter(TURNS_KEY, 2)
	
func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.PLAY_PHASE_START, 
	func(card, event)->void:
		await GameActions.draw_cards(card.owner, 1)
		await ZoneManager.move_to(card, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.DEATH)
	,
	func(card, event)->bool:
		return not card.has_counter(TURNS_KEY)
	),
		Ability.new(Events.START_PHASE_START, 
	func(card, event)->void:
		card.tick_counter(TURNS_KEY)
	)]
