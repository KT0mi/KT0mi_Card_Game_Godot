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
			func(src:CardInstance, candidate:CardInstance) -> bool:
				return candidate.is_creature() and candidate.owner == src.owner,
			func(playability:bool, src:CardInstance, target:CardInstance) -> bool:
				print("Pantagruel Counter: %d" % src.get_counter(COUNT_KEY))
				if not src.has_counter(COUNT_KEY):
					print("pantagruel_the_giant: Card not playable. Reason: Can only play one card per turn.")
					return false
				return playability,
			ContinuousEffect.Layer.DELTA,
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
				var sacrifice := e.card
				
				GameActions.try_add_attack_modifier(c, StatModifer.delta(sacrifice.get_attack(), c))
				GameActions.try_add_endurance_modifier(c, StatModifer.delta(sacrifice.get_endurance(), c))
				GameActions.try_kill_card(sacrifice)
				
				c.tick_counter(COUNT_KEY),
			func(c:CardInstance,e:PlayCardEvent)->bool:return c.has_counter(COUNT_KEY) and e.card.is_creature()
		)
	]
