extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_bomber"
	card_name = "Goblin Bomber"
	card_text = "Quick. When this card attacks, it deals 1 damage to your player card and dies."
	gate = CardGate.BasicGate(29)
	attack = 4
	endurance = 1
	
func _build_abilities() -> Array[Ability]:
	return [
		CardKeywords.QUICK_ABILITY(),
		Ability.new(
			Events.ATTACK_RESOLVED,
			func(c:CardInstance, e:AttackEvent):
				DamagePipeline.apply_damage(c.owner.get_player_card(), 1, c)
				GameActions.try_kill_card(c),
			func(c:CardInstance, e:AttackEvent) -> bool:
				return e.attacker == c,
		)
	]
