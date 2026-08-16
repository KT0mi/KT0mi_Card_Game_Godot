extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_captain"
	card_name = "Goblin Captain"
	card_text = "If played on Lane 1, gain +1/+1"
	gate = CardGate.BasicGate(25)
	attack = 2
	endurance = 3
	sets = ["goblin_forces"]

func _build_abilities() -> Array[Ability]:
	#TODO
	return [
		Ability.new(
			Events.PLAY_CARD_RESOLVED,
			func(c, e): 
				print("goblin_captain: Effect Resolved")
				GameActions.try_add_attack_modifier(c, StatModifer.delta(1,c))
				GameActions.try_add_endurance_modifier(c, StatModifer.delta(1,c)),
			func(c : CardInstance, e : PlayCardEvent) -> bool: return e.card == c and c.lane == 0
		)
	]
