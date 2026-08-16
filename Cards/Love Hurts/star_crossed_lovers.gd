extends CreatureCardDefinition

func _init() -> void:
	id = &"star_crossed_lovers"
	card_name = "Star-Crossed Lovers"
	card_text = "Can only enter battle if there is another 'Star-Crossed Lovers' card in the arena. When this card dies, kill all other 'Star-Crossed Lovers' in the arena"
	gate = CardGate.BasicGate(25)
	attack = 5
	endurance = 1
	sets = ["love_hurts"]

func is_battle_ready(_card: CardInstance) -> bool:
	for c in GameState.all_cards_in_arena().duplicate():
		if c.get_id() == self.id:
			return true
	return false
	

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.KILL_RESOLVED,
			_star_crossed_lovers_effect,
			func(c,e:DeathEvent) -> bool: return e.card == c
		)
	]

func _star_crossed_lovers_effect(_card : CardInstance, _event: DeathEvent) -> void:
	for c in GameState.all_cards_in_arena().duplicate():
		GameActions.try_kill_card(c)
