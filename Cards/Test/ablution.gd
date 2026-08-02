extends SpellCardDefinition

func _init() -> void:
	id = &"ablution"
	card_name = "Ablution"
	card_text = "Choose 1 creature from your board: +1 Attack, -1 Endurance"
	cast_type = SpellCardDefinition.CastType.INSTANT
	sets = [&"blood_empire"]

func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	var targetA : Array = await ChoiceManager.request(
		"Choose 1 creature from your board",
		card.owner.arena.duplicate(),
		card.owner,
		1,
		1
		)
	var t : CardInstance = targetA[0]
	
	await CardMutationPipeline.modify_attack(t, 1)
	await CardMutationPipeline.modify_endurance(t, -1)
