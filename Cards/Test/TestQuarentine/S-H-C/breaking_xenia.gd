extends SpellCardDefinition

func _init() -> void:
	id = &"breaking_xenia"
	card_name = "Breaking Xenia"
	card_text = "Give +10 endurance to your opponent's player card. At the end of his turn deal -12 damage to his player card."
	gate = CardGate.BasicGate(15)
	cast_type = CastType.PERSISTENT

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	GameActions.try_modify_endurance(
		GameState.opponent_of(card.owner).get_player_card(),
		StatModifer.delta(10, card, "+10 Endurance")
	)

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.END_PHASE_END,
			func(c,_e): 
			DamagePipeline.apply_damage(
				GameState.opponent_of(c.owner).get_player_card(),
				12,
				c
			)
			ZoneManager.move_to(c, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE),
			func(c,e) -> bool: return e.player == GameState.opponent_of(c.owner).get_player_card(),
		)
	]
