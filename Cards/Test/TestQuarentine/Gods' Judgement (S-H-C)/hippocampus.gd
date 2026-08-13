extends CreatureCardDefinition

func _init() -> void:
	id = &"hippocampus"
	card_name = "Hippocampus"
	card_text = "Whenever the opposing player plays a creature to their arena, this card gets +2 Attack"
	gate = CardGate.BasicGate(15)
	attack = 1
	endurance = 3
	sets = ["gods_judgement"]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.PLAY_CARD_RESOLVED,
			func(c : CardInstance, e: PlayCardEvent):
				GameActions.try_modify_attack(c, StatModifer.delta(2, c)),
			func(c : CardInstance, e : PlayCardEvent) -> bool:
				return e.player == GameState.opponent_of(c.owner) and c.is_creature(),
		)
	]
