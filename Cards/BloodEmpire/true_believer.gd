extends CreatureCardDefinition

func _init() -> void:
	id = &"true_believer"
	card_name = "True Believer"
	card_text = "When this card dies, choose 1 target and damage it for 1."
	attack = 1
	endurance = 2
	sets = [&"blood_empire"]

func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.KILL_REQUEST,
	func(card, event) -> void:
		var result := await ChoiceManager.request(
			"Choose a target and damage it for 1.",
			GameState.all_cards_in_target_areas(),
			1,
			1,
			card.owner
		)
		var target := result[0] as CardInstance
		if target == null:
			push_warning("true_believer: Ability: Wrong type for 'target' variable.")
			return
		DamagePipeline.apply_damage(target, 1)
	,
	func(card, event) -> bool: return event.card == card
	)]
