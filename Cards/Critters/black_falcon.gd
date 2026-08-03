extends CreatureCardDefinition

func _init() -> void:
	id = &"black_falcon"
	card_name = "Black Falcon"
	card_text = "This card cannot be damaged by the opposing player card"
	gate = CardGate.BasicGate(15)
	attack = 2
	endurance = 1
	
func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.DAMAGE_REQUEST,
			func(_card : CardInstance, event : DamageEvent) -> void: event.cancelled,
			func(card : CardInstance, event : DamageEvent) -> bool: return event.source == GameState.opponent_of(card.owner)
		)
	]
