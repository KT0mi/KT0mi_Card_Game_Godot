extends CreatureCardDefinition

func _init() -> void:
	id = &"librarian"
	card_name = "Librarian"
	card_text = "Before this card attacks draw 1 card."
	attack = 1
	endurance = 1
	sets = [&"blood_empire"]

func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.ATTACK_REQUEST,
	func(card, event) -> void:
		GameActions.draw_cards(card.owner, 1)
	,
	func(card, event) -> bool: return event.attacker == card
	)]
