extends SpellCardDefinition

func _init() -> void:
	id = &"feeding"
	card_name = "Feeding"
	card_text = "Choose any 1 creature card in the arena, +1 Endurance"
	gate = CardGate.BasicGate(25)
	cast_type = CastType.INSTANT
	sets = [&"critters"]
	
func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	var tA : Array = await ChoiceManager.request(
		"Choose any 1 creature card in the arena:",
		
		GameState.all_cards_in_arena().duplicate(),
		card.owner
	)
	
	var target : CardInstance = tA[0]
	if target == null:
		return
	
	GameActions.try_modify_endurance(target, StatModifer.delta(1, card))
