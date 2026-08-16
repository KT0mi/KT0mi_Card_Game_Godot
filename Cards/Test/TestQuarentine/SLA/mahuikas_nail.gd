extends SpellCardDefinition

func _init() -> void:
	id = &"mahuikas_nail"
	card_name = "Mahuika's Nail"
	card_text = "Deal 8 damage randomly devided by all arena cards and the opponent's player card"
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT
	sets = ["fiery_tradition"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	var candidates : Array[CardInstance] = []
	candidates.append_array(GameState.all_cards_in_arena())
	candidates.append(GameState.opponent_of(card.owner).get_player_card())
	
	for i in range(8):
		await DamagePipeline.apply_damage(
			candidates.pick_random(),
			CheckSystem.effect_damage_of(card, 1),
			card
			)
