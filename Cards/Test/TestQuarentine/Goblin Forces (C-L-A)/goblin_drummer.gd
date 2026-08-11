extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_drummer"
	card_name = "Goblin Drummer"
	card_text = "When played, all of your arena cards get +1/+1"
	gate = CardGate.BasicGate(20)
	attack = 1
	endurance = 1
	sets = ["goblin_forces"]

func _build_abilities() -> Array[Ability]:
	return[
		Ability.new(
			Events.PLAY_CARD_RESOLVED,
			_goblin_drummer_effect,
			func(c, e:PlayCardEvent) -> bool: return e.card == c
		)
	]
	
func _goblin_drummer_effect(card : CardInstance, event: PlayCardEvent) -> void:
	for c : CardInstance in card.owner.arena():
		if c.is_creature():
			GameActions.try_modify_attack(c, StatModifer.delta(1, card))
			GameActions.try_modify_endurance(c, StatModifer.delta(1, card))
