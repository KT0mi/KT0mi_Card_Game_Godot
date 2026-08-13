extends SpellCardDefinition

func _init() -> void:
	id = &"curse_of_artemis"
	card_name = "Curse of Artemis"
	card_text = "Choose 1 card from the arena: Kill it and put a 3/3 'Stag' in it's place."
	gate = CardGate.BasicGate(10)
	cast_type = CastType.INSTANT
	sets = ["gods_judgement"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance] = GameState.all_cards_in_arena().duplicate()
	
	if candidates.is_empty():
		push_warning("curse_of_artemis: Effect not resolved. Reason: No valid candidates")
		return
	
	var tA := await ChoiceManager.request(
		"Choose 1 card from the arena:",
		Events.EFFECT_TAG,
		candidates,
		card.owner
	)
	
	var target :CardInstance= tA[0]
	if target == null:
		push_warning("curse_of_artemis: Effect not resolved. Reason: No valid target")
		return
	
	var l := target.lane
	await GameActions.try_kill_card(target)
	await GameActions.try_summon_card(target.owner, &"stag", Zone.Type.ARENA, l)
