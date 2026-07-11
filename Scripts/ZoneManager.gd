extends Node
##Autoload

##Handles zone changes in cards
#The only place any card's current_zone should actually change
#Also makes sure all cards are followed when changing zones

#signal to sync visuals - seperate from game logic
signal card_zone_changed(card: CardInstance, from_zone: Zone.Type, to_zone: Zone.Type)

func move_to(card: CardInstance, to_zone: Zone.Type,
	reason: ZoneChangeEvent.Reason = ZoneChangeEvent.Reason.MANUAL) -> void:
	var from_zone := card.current_zone
	var player := card.owner
	
	player.zone_array(from_zone).erase(card)
	player.zone_array(to_zone).append(card)
	card.current_zone = to_zone
	
	#Set card current endurance if creature
	if to_zone == Zone.Type.ARENA and card.is_creature():
		card.current_endurance = card.definition.endurance
		
	card_zone_changed.emit(card, from_zone, to_zone)
	await TriggerSystem.emit(Events.ZONE_CHANGE, 
		ZoneChangeEvent.new(card, from_zone, to_zone, reason))
