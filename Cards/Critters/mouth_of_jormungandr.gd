extends CreatureCardDefinition

func _init() -> void:
	id = &"mouth_of_jormungandr"
	card_name = "Mouth of Jörmungandr"
	card_text = "This card can only attack if you have both 'Eye of Jörmungandr' and 'Body of Jörmungandr' in your arena."
	gate = CardGate.BasicGate(15)
	attack = 10
	endurance = 10
	sets = [&"critters"]

func _build_abilities() -> Array[Ability]:
	return [Ability.new(Events.ATTACK_REQUEST, 
	_jormungandr_effect,
	func(card, event) -> bool: return event.attacker == card,	
	)]

func _jormungandr_effect(card: CardInstance, event: AttackEvent) -> void:
	var has_eye:bool=false
	var has_body:bool=false
	for c in card.owner.arena.duplicate():
		if c.get_id() == &"eye_of_jormungandr":
			has_eye = true
		elif c.get_id() == &"body_of_jormungandr":
			has_body = true
	
	if not has_body or not has_eye:
		event.cancelled = true
