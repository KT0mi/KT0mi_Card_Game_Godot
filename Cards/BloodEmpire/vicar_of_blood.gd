extends CreatureCardDefinition

func _init() -> void:
	id = &"vicar_of_blood"
	card_name = "Superior, Dignified, High Vicar of Blood"
	card_text = "Whenever a card deals damage, double it."
	is_special = true
	attack = 2
	endurance = 5
	sets = [&"blood_empire"]

func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.DAMAGE_REQUEST,
	func(card, event) -> void:
		event.amount *= 2
	,
	func(card, event) -> bool: return true
	)]
