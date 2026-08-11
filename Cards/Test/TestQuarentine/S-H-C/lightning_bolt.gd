extends SpellCardDefinition

func _init() -> void:
	id = &"lightning_bolt"
	card_name = "Lightning Bolt"
	card_text = "Deal 5 damage to any opponent's creature on lane 2, and 3 damage to the other lanes."
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var opp_arena : Array[CardInstance] = GameState.opponent_of(card.owner).arena_lanes.duplicate()
	if opp_arena[1] != null:
		await DamagePipeline.apply_damage(opp_arena[1], 5, card)
		
	if opp_arena[0] != null:
		await DamagePipeline.apply_damage(opp_arena[0], 3, card)
		
	if opp_arena[2] != null:
		await DamagePipeline.apply_damage(opp_arena[2], 3, card)
