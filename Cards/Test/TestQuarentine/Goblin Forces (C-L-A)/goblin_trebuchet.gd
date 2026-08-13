extends CreatureCardDefinition

func _init() -> void:
	id = &"goblin_trebuchet"
	card_name = "Goblin Trebuchet"
	card_text = "This can only enter battle if it is in lane 2, and both other lanes are filled"
	gate = CardGate.BasicGate(25)
	attack = 5
	endurance = 2
	sets = ["goblin_forces"]
	
func is_battle_ready(card: CardInstance):
	return card.lane == 1 and card.owner.arena_lanes[0] != null and card.owner.arena_lanes[2] != null 
