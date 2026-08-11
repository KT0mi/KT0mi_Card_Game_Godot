extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_mechanic"
	card_name = "Goblin Mechanic"
	card_text = "While this is in the arena, the card in the lane to the right of this gets +1 Attack"
	gate = CardGate.BasicGate(29)
	attack = 1
	endurance = 1
	sets = ["goblin_forces"]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.PLAY_CARD_RESOLVED,
			_goblin_mechanic_effect,
			func(c,e:PlayCardEvent)->bool: return e.card.owner == c.owner 
		),
		Ability.new(
			Events.KILL_RESOLVED,
			_goblin_mechanic_cleanup,
			func(c,e:DeathEvent)->bool: return e.card == c,
		)
	]

func _goblin_mechanic_cleanup(card: CardInstance, event: DeathEvent) -> void:
	if card.lane >= card.owner.ARENA_LANES-1:
		return
	
	var c : CardInstance = card.owner.arena_lanes[card.lane+1]
	
	if c != null:
		c.clear_modifiers_from(card)

func _goblin_mechanic_effect(card:CardInstance, _event: PlayCardEvent) -> void:
	if card.lane >= card.owner.ARENA_LANES-1:
		return
	
	var c : CardInstance = card.owner.arena_lanes[card.lane+1]
	
	if c != null:
		GameActions.try_modify_attack(c, StatModifer.delta(1, card))
