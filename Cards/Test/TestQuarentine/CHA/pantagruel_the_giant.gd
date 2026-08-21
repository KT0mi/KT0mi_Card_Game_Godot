extends CreatureCardDefinition

func _init() -> void:
	id = &"pantagruel_the_giant"
	card_name = "Pantagruel, The Giant"
	card_text = "While this card is in play: You can only play one creature card per turn, once you play it, sacrifice it and add it's Attack and Endurance to this card."
	is_special = true
	gate = CardGate.BasicGate(15)
	attack = 5
	endurance = 5
	sets = ["pantagruel_islet"]
	
const COUNT_KEY := &"ptg_count"

func _build_continuous_effects() -> Array[ContinuousEffect]:
	return [
		ContinuousEffect.new(
			ContinuousEffect.Kind.PLAYABILITY,
			func(src:CardInstance, ctx:PlayabilityCheck) -> bool:
				return ctx.injectable == PlayabilityCheck.Injectable.LANE_OPEN \
					and ctx.card.is_creature() and ctx.card.owner == src.owner,
			func(_value:bool, src:CardInstance, ctx:PlayabilityCheck) -> bool:
				print("Pantagruel Counter: %d" % src.get_counter(COUNT_KEY))
				if not src.has_counter(COUNT_KEY):
					print("pantagruel_the_giant: Card not playable. Reason: Can only play one card per turn.")
					return false
				return true,
			ContinuousEffect.Layer.SET,
			"Can only play 1 creature per turn"
		)
	]

func _build_abilities() -> Array[Ability]:
	return[
		Ability.new(
			Events.PLAY_PHASE_START,
			func(c:CardInstance,_e): c.set_counter(COUNT_KEY,1),
			func(c:CardInstance,e:PhaseEvent)->bool:return e.player == c.owner,
		),
		Ability.new(
			Events.PLAY_CARD_RESOLVED,
			func(c:CardInstance,e:PlayCardEvent):
				print("Resolving pantagruel_the_giant's effect")
				var sacrifice := e.card
				
				GameActions.try_add_attack_modifier(c, StatModifer.delta(sacrifice.get_attack(), c))
				GameActions.try_add_endurance_modifier(c, StatModifer.delta(sacrifice.get_endurance(), c))
				GameActions.try_kill_card(sacrifice)
				
				c.tick_counter(COUNT_KEY),
				
			func(c:CardInstance,e:PlayCardEvent)->bool: 
				print("Attempting to resolve pantagruel_the_giant's effect. variables:\nCard being played: %s\nPlayer playing card: %s" % [e.card.definition.card_name, e.player.get_player_card().definition.card_name])
				return e.card.is_creature() and e.player == c.owner and e.card != c,
		)
	]
