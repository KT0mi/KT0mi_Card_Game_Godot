extends CreatureCardDefinition

func _init() -> void:
	id = &"great_forest_sloth"
	card_name = "Great Forest Sloth"
	card_text = "This card has 'Dazed' for it's first 3 turns on the arena."
	gate = CardGate.BasicGate(10)
	attack = 10
	endurance = 12
	sets = ["pantagruel_islet"]

const TIMER_KEY := "gfs_timer"

func get_display_text(instance: CardInstance) -> String:
	return "This card has 'Dazed' for it's first %s turns on the arena." \
		% CardText.dynamic(instance.counters.get(TIMER_KEY, 3))

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.PLAY_CARD_RESOLVED,
			func(c:CardInstance,e): c.set_counter(TIMER_KEY, 3),
			func(c,e)->bool: return e.card == c
		),
		Ability.new(
			Events.END_PHASE_END,
			_great_forest_sage_effect,
		)
	]

func _great_forest_sage_effect(card:CardInstance, event:PhaseEvent)->void:
	if card.tick_counter(TIMER_KEY) > 0:
		card.set_flag(CardKeywords.DAZED, true)
