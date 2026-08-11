extends SpellCardDefinition

func _init() -> void:
	id = &"owl_of_minerva"
	card_name = "Owl of Minerva"
	card_text = "After 2 turns: Draw 2 cards."
	gate = CardGate.BasicGate(20)
	cast_type = CastType.PERSISTENT

const TIMER_KEY := &"ofm_timer"

func get_display_text(instance: CardInstance) -> String:
	return "After %s turns: Draw 2 cards." \
	 % CardText.dynamic(instance.counters.get(TIMER_KEY, 2))

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	card.set_counter(TIMER_KEY, 2)

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.DRAW_PHASE_START,
			_owl_of_minerva_effect,
			func(c,e) -> bool: return e.player == c.owner,
		)
	]

func _owl_of_minerva_effect(card : CardInstance, event: PhaseEvent) -> void:
	if card.tick_counter(TIMER_KEY) <= 0:
		GameActions.draw_cards(card.owner, 2)
		ZoneManager.move_to(card, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE)
