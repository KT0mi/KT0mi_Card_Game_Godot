extends SpellCardDefinition

func _init() -> void:
	id = &"zeus_wrath"
	card_name = "Zeus' Wrath"
	card_text = "Deal 4 damage to any opponent's creature on lane 2, and 2 damage to the other lanes."
	gate = CardGate.BasicGate(15)
	cast_type = CastType.INSTANT
	sets = ["gods_judgement"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var opp_arena : Array[CardInstance] = GameState.opponent_of(card.owner).arena_lanes.duplicate()
	if opp_arena[1] != null:
		await DamagePipeline.apply_damage(opp_arena[1], 4, card)
		
	if opp_arena[0] != null:
		await DamagePipeline.apply_damage(opp_arena[0], 2, card)
		
	if opp_arena[2] != null:
		await DamagePipeline.apply_damage(opp_arena[2], 2, card)
