extends CreatureCardDefinition

func _init() -> void:
	id = &"robo_blender_1000"
	card_name = "Robo-Blender 1000"
	card_text = "Randomly switch all of the arena card's endurance and attack values."
	gate = CardGate.BasicGate(15)
	attack = 5
	endurance = 5
	sets = ["dr_steelwrights_appliances"]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.PLAY_CARD_RESOLVED,
			_robo_blender_effect,
			func(c:CardInstance, e:PlayCardEvent)->bool: return e.card == c
		)
	]

func _robo_blender_effect(card : CardInstance, _e : PlayCardEvent) -> void:
	var targets := GameState.all_cards_in_arena()
	var stat_bag : Array[int] = []
	
	for t:CardInstance in targets.duplicate():
		stat_bag.append(t.get_attack())
		stat_bag.append(t.get_endurance())
	
	stat_bag.shuffle()
	for t:CardInstance in targets.duplicate():
		var a : int = stat_bag.pop_back()
		await GameActions.try_add_attack_modifier(t, StatModifer.new(
			func(_v)->int: return a, card, "Attack = %d" % a)
		)
		var e : int = stat_bag.pop_back()
		await GameActions.try_add_attack_modifier(t, StatModifer.new(
			func(_v)->int: return e, card, "Endurance = %d" % e)
		)
