extends CreatureCardDefinition

func _init() -> void:
	id = &"black_falcon"
	card_name = "Black Falcon"
	card_text = "This card cannot be damaged by the opposing player card"
	gate = CardGate.BasicGate(20)
	attack = 2
	endurance = 1
	sets = [&"critters"]
	
func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.DAMAGE_REQUEST,
			func(_card : CardInstance, event : DamageEvent) -> void: event.cancelled = true,
			func(card : CardInstance, event : DamageEvent) -> bool: return event.source == GameState.opponent_of(card.owner).get_player_card() and event.target == card
		)
	]
