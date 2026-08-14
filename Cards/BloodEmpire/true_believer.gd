extends CreatureCardDefinition

func _init() -> void:
	id = &"true_believer"
	card_name = "True Believer"
	card_text = "When this card dies, choose 1 target and damage it for 1."
	attack = 1
	endurance = 2
	gate = CardGate.None()
	sets = [&"blood_empire"]

func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.KILL_REQUEST,
	func(card, event) -> void:
		var target := await ChoiceManager.request_card(
			"Choose a target and damage it for 1.",
			GameState.all_cards_in_target_areas(),
			card.owner,
			ChoiceContext.new(
				ChoiceContext.Origin.CARD_EFFECT,
				ChoiceContext.Intent.DAMAGE,
				card,
				card.owner,
				1)
		)
		
		await DamagePipeline.apply_damage(target, 1, card)
	,
	func(card, event) -> bool: return event.card == card
	)]
