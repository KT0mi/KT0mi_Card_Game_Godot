extends SpellCardDefinition

func _init() -> void:
	id = &"the_breakup"
	card_name = "The Breakup"
	card_text = "Every 'Bleeding Heart' card in your SpellBook resolves: For each resolved card, Draw 1 card and deal 1 damage to your opponent"
	gate = CardGate.BasicGate(15)
	cast_type = CastType.INSTANT
	sets = ["love_hurts"]


func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	#TODO COUNTER MANIPULATION TO BE DONE
	var count : int = 0
	for c in card.owner.spellbook:
		if c.get_id() == CardKeywords.BLEEDING_HEART:
			#TODO NEED TO ADD REMOTE SPELL RESOLVING OR REMOTE COUNTER RESOLVING
			c.set_counter(&"bh_timer", 0)
			c.definition.get_abilities()[0].effect.call(c, PhaseEvent.new(card.owner))
			#await DamagePipeline.apply_damage(c.owner.get_player_card(), 2, c)
			#await ZoneManager.move_to(c, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE)
			count +=1
	
	await GameActions.draw_cards(card.owner, count, DrawCardEvent.Reason.EFFECT)
	await DamagePipeline.apply_damage(GameState.opponent_of(card.owner).get_player_card(), count, card)
	
