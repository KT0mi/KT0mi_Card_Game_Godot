extends CreatureCardDefinition

func _init() -> void:
	id = &"homeoconstruct"
	card_name = "Homeoconstruct"
	card_text = "When played, if there isn't any 'Blood Wall' cards in your arena, deal 2 damage to your player card"
	attack = 3
	endurance = 3
	gate = CardGate.BasicGate(29)
	sets = [&"blood_empire"]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(Events.PLAY_CARD_RESOLVED,
		_homeoconstruct_ability,
		func(card : CardInstance, event : PlayCardEvent): return event.card == card
		)
	]

func _homeoconstruct_ability(card: CardInstance, event: PlayCardEvent) -> void:
	
	for c in card.owner.arena:
		if c.get_id() == &"blood_wall":
			return
	
	await DamagePipeline.apply_damage(card.owner.get_player_card(), 2, card)
