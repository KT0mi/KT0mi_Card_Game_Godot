extends CreatureCardDefinition

func _init() -> void:
	id = &"wolf_mother"
	card_name = "Wolf Mother"
	card_text = "Whenever any of your creature cards dies, gain +1 Attack"
	gate = CardGate.BasicGate(26)
	attack = 2
	endurance = 2
	sets = [&"critters"]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.KILL_RESOLVED,
			_wolf_mother_ability,
			_wolf_mother_con
		)
	]

func _wolf_mother_con(card: CardInstance, event:DeathEvent) -> bool:
	if event.card.owner == card.owner:
		if event.card.is_creature():
			return true
	return false

func _wolf_mother_ability(card : CardInstance, _event : DeathEvent) -> void:
	GameActions.try_modify_attack(card, StatModifer.delta(1))
