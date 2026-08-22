extends SpellCardDefinition

func _init() -> void:
	id = CardKeywords.BLEEDING_HEART
	card_name = "Bleeding Heart"
	card_text = "After 2 of your turns: Deal 2 damage to your player card."
	gate = CardGate.None()
	cast_type = CastType.PERSISTENT
	sets = ["love_hurts"]

const TIMER_KEY := &"bh_timer"

func get_display_text(_instance: CardInstance, _context : bool = false) -> String:
	return "After %s of your turns: Deal 2 damage to your player card." \
		% CardText.dynamic(_instance.counters.get(TIMER_KEY, 2))

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	card.set_counter(TIMER_KEY, 2)

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.PLAY_PHASE_START,
			func(c:CardInstance, _e:PhaseEvent):
				if c.tick_counter(TIMER_KEY) <= 0:
					await DamagePipeline.apply_damage(c.owner.get_player_card(), 2, c)
					await ZoneManager.move_to(c, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE),
			func(c:CardInstance,e:PhaseEvent): return e.player == c.owner,
		)
	]
