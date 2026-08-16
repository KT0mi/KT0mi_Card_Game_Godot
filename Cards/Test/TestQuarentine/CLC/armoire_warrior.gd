extends CreatureCardDefinition

func _init() -> void:
	id = &"armoire_warrior"
	card_name = "Armoire Warrior"
	card_text = "Taunt. This card cannot attack. Whenever anything attacks this card, it gets -1 Attack."
	gate = CardGate.BasicGate(20)
	attack = 0
	endurance = 6
	sets = ["dr_tetheus_appliances"]

func is_battle_ready(_card: CardInstance) -> bool:
	return false

func _build_abilities() -> Array[Ability]:
	return [
		CardKeywords.TAUNT_ABILITY(),
		Ability.new(
			Events.ATTACK_RESOLVED,
			func(c:CardInstance, e:AttackEvent):
				GameActions.try_add_attack_modifier(e.attacker, StatModifer.delta(-1, c)),
			func(c:CardInstance, e:AttackEvent)->bool: return e.target == c
		)
	]
