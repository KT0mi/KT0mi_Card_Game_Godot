extends SpellCardDefinition

func _init() -> void:
	id = &"magma_burst"
	card_name = "Magma Burst"
	card_text = "Choose any card in play: Damage it for 1"
	gate = CardGate.None()
	cast_type = CastType.INSTANT
	damage_tags = [&"magma_burst"]
	sets = ["fiery_tradition"]
	
func get_display_text(card: CardInstance) -> String:
	return "Choose any card in play: Damage it for %d" % CheckSystem.effect_damage_of(card, 1)

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var target := await ChoiceManager.request_card(
		"Choose any card in play:",
		GameState.all_cards_in_target_areas(),
		card.owner,
		ChoiceContext.DAMAGE_EFFECT(card, CheckSystem.effect_damage_of(card, 1))
	)
	
	await DamagePipeline.apply_damage(target, CheckSystem.effect_damage_of(card, 1), card)
	
