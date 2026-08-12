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
			Events.ZONE_CHANGE,
			func(c, e): 
				GameActions.try_modify_attack(c, StatModifer.delta(1,c))
				GameActions.try_modify_endurance(c, StatModifer.delta(1,c)),
			func(c, e : ZoneChangeEvent): e.target == c and e.lane == 0
		)
	]
