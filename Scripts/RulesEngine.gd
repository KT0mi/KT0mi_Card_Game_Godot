extends Node
##Autoload

#Holds all global rules that don't belong to any card
#Does not actually decide if a certain thing is legal
#That is relegated to GameActions

signal player_defeated(player: Player)

func check_state_based_actions() -> void:
	#Creatures die when their health is at 0 in the end turn phase 
	#Creatures lose their dazed status at the end of the turn if they have them
	for player in GameState.players():
		#Cards in Arena
		for c in player.arena.duplicate(): 
		#Creatures lose dazed
			var card : CardInstance = c
			card.set_flag(CardStatus.DAZED, false)
			
			if card.get_endurance() <= 0:
				#Card Death - Specific event when a card ends the turn with no endurance - cancellable
				GameActions.try_kill_card(card)
		
		
		#Check for player death - will move to a persistent check later
		for card in player.player_zone.duplicate():
			if card.get_endurance() <= 0:
				player_defeated.emit(player)

func setup_match() -> void:
	#Rules for match setup
	#E.g: Players get x amount of cards, players get special card in hand
	for player in GameState.players():
		var special_card : CardInstance
		for card in player.deck.duplicate():
			if card.definition.is_special:
				special_card = card
	
		#If a player has a special card in his deck, draw it and draw 4 more cards
		#If not, draw 7 cards
		if special_card:
			player.deck.erase(special_card)
			player.hand.append(special_card)
			ZoneManager.move_to(special_card, Zone.Type.HAND, ZoneChangeEvent.Reason.DRAW)
			GameActions.draw_cards(player, 4)
		else:
			GameActions.draw_cards(player, 7)
	
	#var face_card := CardInstance.new(CardDatabase.get_definition(&"player_face"), player)
	#await ZoneManager.move_to(face_card, Zone.Type.PLAYER, ZoneChangeEvent.Reason.MANUAL)
