extends Node
##Autoload

##Handles zone changes in cards
#The only place any card's current_zone should actually change
#Also makes sure all cards are followed when changing zones

#signal to sync visuals - seperate from game logic
signal card_zone_changed(card: CardInstance, from_zone: Zone.Type, to_zone: Zone.Type)

func move_to(
	card: CardInstance, 
	to_zone: Zone.Type,
	reason: ZoneChangeEvent.Reason = ZoneChangeEvent.Reason.MANUAL, 
	lane: int = -1) -> void:
	
	var from_zone := card.current_zone
	var player := card.owner
	
	if from_zone == Zone.Type.ARENA:
		player.arena_lanes[card.lane] = null
		card.lane = -1
	else:
		player.zone_array(from_zone).erase(card)
	
	if to_zone == Zone.Type.ARENA:
		player.arena_lanes[lane] = card
		card.lane = lane
	else:
		player.zone_array(to_zone).append(card)
	
	card.current_zone = to_zone
	card_zone_changed.emit(card, from_zone, to_zone)
	await TriggerSystem.emit(Events.ZONE_CHANGE, 
		ZoneChangeEvent.new(card, from_zone, to_zone, reason))
