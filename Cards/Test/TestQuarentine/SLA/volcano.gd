extends CreatureCardDefinition

func _init() -> void:
	id = &"volcano"
	card_name = "Volcano"
	card_text = "At the start of your Draw Phase: Add 1 'Magma Burst' to your hand."
	gate = CardGate.BasicGate(15)
	attack = 0
	endurance = 10
	sets = ["fiery_tradition"]
	
func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.DRAW_PHASE_START,
			func(c:CardInstance,e:PhaseEvent):
				await GameActions.try_summon_card(c.owner, &"magma_burst", Zone.Type.HAND),
			func(c:CardInstance,e:PhaseEvent) -> bool: return e.player == c.owner
		)
	]
