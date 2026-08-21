extends SpellCardDefinition

func _init() -> void:
	id = &"pyroclastic_flow"
	card_name = "Pyroclastic Flow"
	card_text = "Deal 1 damage to the opponent, on your next turn deal 1 again, then deal 3."
	gate = CardGate.BasicGate(20)
	cast_type = CastType.PERSISTENT
	sets = ["fiery_tradition"]
	
const COUNTER_KEY := &"pf_counter"

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	card.set_counter(COUNTER_KEY, 2)
	await DamagePipeline.apply_damage(GameState.opponent_of(card.owner).get_player_card(), 1, card)

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.PLAY_PHASE_START,
			func(c:CardInstance, _e:PhaseEvent):
				if c.get_counter(COUNTER_KEY) == 1:
					await DamagePipeline.apply_damage(GameState.opponent_of(c.owner).get_player_card(), 3, c)
				else:
					await DamagePipeline.apply_damage(GameState.opponent_of(c.owner).get_player_card(), 1, c)
				
				if c.tick_counter(COUNTER_KEY):
					await ZoneManager.move_to(c, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE),
			func(c:CardInstance, e:PhaseEvent) -> bool: return e.player == c.owner,
		)
	]
