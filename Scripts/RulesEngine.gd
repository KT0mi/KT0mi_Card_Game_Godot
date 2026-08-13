extends Node
##Autoload

#Holds all global rules that don't belong to any card
#Does not actually decide if a certain thing is legal
#That is relegated to GameActions

signal player_defeated(player: Player)

func check_state_based_actions() -> void:
	#Creatures die when their health is at 0
	for player in GameState.players():
		#Cards in Arena
		for c in player.arena().duplicate(): 
			var card : CardInstance = c
			if card.get_endurance() <= 0 and card.current_zone != Zone.Type.GRAVEYARD:
				#Card Death - Specific event when a card ends the turn with no endurance - cancellable
				GameActions.try_kill_card(card)
		#Check for player death
		for card in player.player_zone.duplicate():
			if card.get_endurance() <= 0:
				player_defeated.emit(player)

func check_end_phase_state() -> void:
	#Creatures lose their dazed status at the end of the turn if they have them
	for player in GameState.players():
		#Cards in Arena
		for c in player.arena().duplicate(): 
		#Creatures lose dazed
			var card : CardInstance = c
			card.set_flag(CardKeywords.DAZED, false)

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
			await ZoneManager.move_to(special_card, Zone.Type.HAND, ZoneChangeEvent.Reason.DRAW)
			await GameActions.draw_cards(player, 4, DrawCardEvent.Reason.TURN)
		else:
			await GameActions.draw_cards(player, 7, DrawCardEvent.Reason.TURN)
	
	do_mulligan()
	
	#var face_card := CardInstance.new(CardDatabase.get_definition(&"player_face"), player)
	#await ZoneManager.move_to(face_card, Zone.Type.PLAYER, ZoneChangeEvent.Reason.MANUAL)

func do_mulligan() -> void:
	for player in GameState.players():
		var candidates : Array[CardInstance]
		for c : CardInstance in player.hand.duplicate():
			if c.definition.is_special:
				continue
			candidates.append(c)
		
		var m_cards : Array = await ChoiceManager.request(
			"Choose any cards in your hand to mulligan",
			candidates,
			player,
			0,
			candidates.size(),
			ChoiceContext.MULLIGAN(player)
		)
		
		if m_cards.is_empty() or m_cards == null: 
			print("RulesEngine: No valid cards in selected")
			return
		
		for c : CardInstance in m_cards:
			ZoneManager.move_to(c, Zone.Type.DECK, ZoneChangeEvent.Reason.MANUAL)
		
		player.deck.shuffle()
		
		await GameActions.draw_cards(player, m_cards.size(), DrawCardEvent.Reason.TURN)
