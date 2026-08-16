extends SpellCardDefinition

func _init() -> void:
	id = &"breaking_xenia"
	card_name = "Breaking Xenia"
	card_text = "Give +5 endurance to your opponent's player card. At the end of his turn deal 6 damage to his player card."
	gate = CardGate.BasicGate(15)
	cast_type = CastType.PERSISTENT
	sets = ["gods_judgement"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	GameActions.try_add_endurance_modifier(
		GameState.opponent_of(card.owner).get_player_card(),
		StatModifer.delta(5, card, "+5 Endurance")
	)

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.START_PHASE_START,
			func(c,_e): 
			DamagePipeline.apply_damage(
				GameState.opponent_of(c.owner).get_player_card(),
				6,
				c
			)
			ZoneManager.move_to(c, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE),
			func(c,e) -> bool: return e.player == c.owner,
		)
	]
