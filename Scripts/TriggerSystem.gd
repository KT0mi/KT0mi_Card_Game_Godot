extends Node
##Autoload

func emit(event_name: StringName, event: GameEvent) -> void:
	print("TriggerSystem: Emit trigger for event: %s" % event_name)
	for entry in _gather_candidates(event_name):
		var card: CardInstance = entry.card
		var ability: Ability = entry.ability
		
		if not GameState.is_ability_active(card, ability):
			continue
		
		print("TriggerSystem: Found possible candidate for event trigger, running condition")
		if ability.condition.call(card, event):
			print("TriggerSystem: Triggered checked resolving card ability")
			await ability.resolve(card, event)

func _gather_candidates(event_name: StringName) -> Array:
	var result := []
	for player in GameState.turn_order():
		for card in player.all_cards():
			for ability in card.definition.get_abilities():
				if ability.trigger == event_name:
					result.append({card = card, ability = ability})
	return result
