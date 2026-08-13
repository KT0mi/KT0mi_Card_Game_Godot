extends SpellCardDefinition

func _init() -> void:
	id = &"curse_of_hera"
	card_name = "Curse of Hera"
	card_text = "For the next 3 times the opposing player plays a card: Deal 1 damage to his player card."
	gate = CardGate.BasicGate(15)
	cast_type = CastType.PERSISTENT
	sets = ["gods_judgement"]

const CURSE_KEY = &"coh_counter"

func get_display_text(_instance: CardInstance) -> String:
	return "For the next %s times the opposing player plays a card: Deal 1 damage to his player card" \
		% CardText.dynamic(_instance.counters.get(CURSE_KEY, 3))

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	card.set_counter(CURSE_KEY, 3)
	
func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.PLAY_CARD_RESOLVED,
			_curse_of_hera_effect,
			func(c:CardInstance, e:PlayCardEvent) -> bool:
				return e.player == GameState.opponent_of(c.owner),
			)
	]

func _curse_of_hera_effect(card :CardInstance, _event: PlayCardEvent) -> void:
	DamagePipeline.apply_damage(GameState.opponent_of(card.owner).get_player_card(), 1, card)
	
	if card.tick_counter(CURSE_KEY) <= 0:
		ZoneManager.move_to(card, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE)
