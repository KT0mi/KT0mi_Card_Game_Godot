extends SpellCardDefinition

func _init() -> void:
	id = &"ablution"
	card_name = "Ablution"
	card_text = "Choose 1 creature from your board: +1 Attack, -1 Endurance"
	gate = CardGate.None()
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates := card.owner.arena().duplicate()
	if candidates.is_empty(): return
	
	var t := await ChoiceManager.request_card(
		"Choose 1 creature from your board",
		candidates,
		card.owner,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.BUFF,
			card,
			card.owner
			)
		)
	
	await GameActions.try_modify_attack(t,
	StatModifer.new(
		func(attack) -> int: return attack + 1,
		card,
		"+1 Attack"
		)
	)
	await GameActions.try_modify_endurance(t,
	StatModifer.new(
		func(endurance) -> int: return endurance - 1,
		card,
		"-1 Endurance"
		)
	)
