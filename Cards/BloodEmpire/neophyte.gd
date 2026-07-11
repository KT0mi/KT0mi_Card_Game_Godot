extends CreatureCardDefinition

func _init() -> void:
	id = &"neophyte"
	card_name = "Neophyte"
	card_text = "When this card dies, choose 1 target and damage it for 1."
	attack = 1
	endurance = 2
	sets = [&"blood_empire"]

func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.KILL_REQUEST,
	func(card, event) -> void:
		GameActions.draw_cards(card.owner, 1)
	,
	func(card, event) -> bool: return event.card == card
	)]
