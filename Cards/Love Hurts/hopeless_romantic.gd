extends CreatureCardDefinition

func _init() -> void:
	id = &"hopeless_romantic"
	card_name = "Hopeless Romantic"
	card_text = "At the start of every battle phase: Spend a 'Bleeding Heart' and deal 1 damage to the opponent."
	gate = CardGate.BasicGate(30)
	attack = 1
	endurance = 2
	sets = ["love_hurts"]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.BATTLE_PHASE_START,
			func(card : CardInstance, e: PhaseEvent):
				for c in card.owner.spellbook:
					if c.get_id() == CardKeywords.BLEEDING_HEART:
						await GameActions.try_kill_card(c)
						await DamagePipeline.apply_damage(GameState.opponent_of(card.owner).get_player_card(), 1, card)
						print("hopeless_romantic: Effect resolved successfully")
						return
				print("hopeless_romantic: Effect failed. Reason: Didn't find any 'Bleeding Heart' card"),
		)
	]
