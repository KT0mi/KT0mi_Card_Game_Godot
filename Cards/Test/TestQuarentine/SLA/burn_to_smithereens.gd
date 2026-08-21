extends SpellCardDefinition

func _init() -> void:
	id = &"burn_to_smithereens"
	card_name = "Burn to Smithereens"
	card_text = "This card counts as a 'Magma Burst'. Choose 1 arena card: Deal 4 damage to it, if it dies deal 1 damage to it's owner"
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT
	damage_tags = [&"magma_burst"]
	sets = ["fiery_tradition"]

func get_display_text(instance: CardInstance) -> String:
	return "This card counts as a 'Magma Burst'. Choose 1 arena card: Deal 4 damage to it, if it dies deal %s damage to it's owner" \
		% CheckSystem.effect_damage_of(instance, 1)

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates :=GameState.all_cards_in_arena().duplicate()
	if candidates.is_empty(): return
	
	var target:=await ChoiceManager.request_card(
		"Choose 1 card from the arena:",
		candidates,
		card.owner,
		ChoiceContext.DAMAGE_EFFECT(card, 4)
	)
	
	await DamagePipeline.apply_damage(target, 4, card, DamageEvent.Reason.CARD_EFFECT)
	
	if target.current_zone == Zone.Type.GRAVEYARD:
		await DamagePipeline.apply_damage(target.owner.get_player_card(), CheckSystem.effect_damage_of(card, 1), card)
