extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_mechanic"
	card_name = "Goblin Mechanic"
	card_text = "While this is in the arena, the card in the lane to the right of this gets +1 Attack"
	gate = CardGate.None()
	attack = 1
	endurance = 1
	sets = ["goblin_forces"]

func _build_continuous_effects() -> Array[ContinuousEffect]:
	return [
		ContinuousEffect.new(
			ContinuousEffect.Kind.ATTACK,
			func(source: CardInstance, candidate: CardInstance) -> bool:
				if source.lane >= source.owner.ARENA_LANES - 1:
					return false
				return candidate == source.owner.arena_lanes[source.lane + 1],
			func(attack : int) -> int:
				return attack + 1,
		)
	]
