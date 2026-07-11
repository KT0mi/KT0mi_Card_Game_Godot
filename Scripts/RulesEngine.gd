extends Node
##Autoload

#Holds all global rules that don't belong to any card
#Does not actually decide if a certain thing is legal
#That is relegated to GameActions

func check_state_based_actions() -> void:
	#Creatures die when their health is at 0 in the end turn phase
	for player in GameState.players():
		for card in player.arena.duplicate(): 
			if card.current_endurance <= 0:
				return

func setup_match() -> void:
	#Rules for match setup
	#E.g: Players get x amount of cards, players get special card in hand
	for player in GameState.players():
		for card in player.deck.duplicate():
			if card.definition.is_special:
				player.deck.erase(card)
				player.hand.append(card)
				card.current_zone = Zone.Type.HAND
				
