extends CreatureCardDefinition

func _init() -> void:
	id = &"bolt_mutt"
	card_name = "Bolt Mutt"
	card_text = "Whenever this card attacks, it's target becomes a random opponent's creature."
	gate = CardGate.BasicGate(25)
	attack = 2
	endurance = 3
	sets = ["dr_steelwrights_appliances"]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.ATTACK_REQUEST,
			_bolt_mutt_effect,
			func(c,e) -> bool: return e.attacker == c,
		)
	]
	
func _bolt_mutt_effect(card:CardInstance, event:AttackEvent) -> void:
	var candidates := GameState.opponent_of(card.owner).arena()
	if candidates.is_empty(): return
	
	event.redirect_target(candidates.pick_random(), card)
