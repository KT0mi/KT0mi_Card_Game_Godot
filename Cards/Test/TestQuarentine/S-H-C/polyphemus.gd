extends CreatureCardDefinition

func _init() -> void:
	id = &"polyphemus"
	card_name = "Polyphemus"
	card_text = "On battle attack: If there are any other creatures in the arena, choose 1 randomly and attack them."
	gate = CardGate.BasicGate(10)
	attack = 8
	endurance = 5

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.ATTACK_REQUEST,
			func(c:CardInstance,e:AttackEvent):
				var candidates : Array[CardInstance] = GameState.all_cards_in_arena().duplicate()
				candidates.erase(c)
				var target : CardInstance = candidates.pick_random()
				if target != null:
					e.redirect_target(target, c),
			func(c:CardInstance,e:AttackEvent) -> bool:
				return TurnController.current_phase == TurnController.Phase.BATTLE \
				and e.attacker == c and not e.redirected,
		)
	]
