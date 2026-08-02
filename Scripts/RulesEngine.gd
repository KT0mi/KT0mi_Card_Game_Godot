extends Node
##Autoload

#Holds all global rules that don't belong to any card
#Does not actually decide if a certain thing is legal
#That is relegated to GameActions

signal player_defeated(player: Player)

func check_state_based_actions() -> void:
	#Creatures die when their health is at 0 in the end turn phase
	for player in GameState.players():
		for card in player.arena.duplicate(): 
			if card.current_endurance <= 0:
				#Card Death - Specific event when a card ends the turn with no endurance - cancellable
				GameActions.try_kill_card(card)
		for card in player.player_zone.duplicate():
			if card.current_endurance <= 0:
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
	
	
