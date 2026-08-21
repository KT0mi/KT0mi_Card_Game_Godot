extends SpellCardDefinition

func _init() -> void:
	id = &"stomach_growl"
	card_name = "Stomach Growl"
	card_text = "If there is a card in the arena with 5 or more Attack and Endurance, draw 1 card."
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT
	sets = ["pantagruel_islet"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	for c : CardInstance in GameState.all_cards_in_arena().duplicate():
		if c.get_attack() >= 5 and c.get_endurance() >= 5:
			await GameActions.draw_cards(card.owner, 1, DrawCardEvent.Reason.EFFECT)
	
