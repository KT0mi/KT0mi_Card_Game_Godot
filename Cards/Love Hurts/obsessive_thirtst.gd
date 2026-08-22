extends SpellCardDefinition

func _init() -> void:
	id = &"obsessive_thirtst"
	card_name = "Obsessive Thirst"
	card_text = "For the next 5 times your player card gets damaged: Add 1 'Bleeding Heart' to your Spellbook"
	gate = CardGate.None()
	cast_type = CastType.PERSISTENT
	sets = ["love_hurts"]
	
const COUNTER_KEY := &"ot_counter"

func get_display_text(instance: CardInstance, _context : bool = false) -> String:
	return "For the next %s times your player card gets damaged: Add 1 'Bleeding Heart' to your Spellbook" \
		% CardText.dynamic(instance.counters.get(COUNTER_KEY, 5))

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	card.set_counter(COUNTER_KEY, 5)

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.DAMAGE_RESOLVED,
			func(c:CardInstance,_e:DamageEvent):
				print("obsessive_thirst: Effect Resolved")
				GameActions.try_summon_card(c.owner, CardKeywords.BLEEDING_HEART, Zone.Type.SPELLBOOK)
				if c.tick_counter(COUNTER_KEY) <= 0:
					ZoneManager.move_to(c, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE),
			func(c:CardInstance,e:DamageEvent) -> bool: return e.target == c.owner.get_player_card()
		)
	]
