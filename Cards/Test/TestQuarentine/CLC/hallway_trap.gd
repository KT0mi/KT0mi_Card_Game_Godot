extends SpellCardDefinition

func _init() -> void:
	id = &"hallway_trap"
	card_name = "Hallway Trap"
	card_text = "Choose 1 arena card. For the next turn: This card becomes a 1/1 card."
	gate = CardGate.BasicGate(20)
	cast_type = CastType.PERSISTENT
	sets = ["dr_tetheus_appliances"]

const TARGET_REF := &"ht_ref"

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates := GameState.all_cards_in_arena()
	if candidates.is_empty(): return #TODO Card has no way to resolve if there are no candidates
	
	var target := await ChoiceManager.request_card(
		"Choose 1 arena card:",
		candidates,
		card.owner,
		ChoiceContext.new(
			ChoiceContext.Origin.CARD_EFFECT,
			ChoiceContext.Intent.DEBUFF,
			card,
			card.owner
		)
	)
	
	card.set_bag(TARGET_REF, target)

func _build_continuous_effects() -> Array[ContinuousEffect]:
	return [
		ContinuousEffect.new(
			ContinuousEffect.Kind.ATTACK,
			func(src:CardInstance, c:CardInstance) -> bool:
				return src.has_bag(TARGET_REF),
			func(v:int, src:CardInstance) -> int:
				return 1,
			ContinuousEffect.Layer.SET
		)
	]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.PLAY_PHASE_START,
			func(c,_e): ZoneManager.move_to(c,Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE),
			func(c,e) -> bool: return e.player == c.owner
		)
	]
