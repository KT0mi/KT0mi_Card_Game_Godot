extends Node
##Autoload

#This holds all gameplay VERBS -> Game actions that may be performed by the
#pure game logic or the cards themselves
#Action shape: check phase legally -> emit a cancellable "_request" event ->
# bail if cancelled -> perform the state change -> emit the "resolved" notification.

func try_play_card(player: Player, card: CardInstance) -> bool:
	print("GameActions: Requested try_play_card action")
	if TurnController.current_phase != TurnController.Phase.PLAY:
		print("GameActions: Failed try_play_card action. Reason: Not in play phase")
		return false
		
	if card.is_creature() and not player.can_add_to_arena():
		print("GameActions: Failed try_play_card action. Reason: Cannot have more than 3 cards in arena")
		return false
		
	var event := PlayCardEvent.new(player, card)
	await TriggerSystem.emit(Events.PLAY_CARD_REQUEST, event)
	if event.cancelled:
		print("GameActions: Failed try_play_card action. Reason: Request intercepted")
		return false
	
	if card.is_creature():
		await ZoneManager.move_to(card, Zone.Type.ARENA, ZoneChangeEvent.Reason.PLAY)
	else:
		await ZoneManager.move_to(card, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.PLAY)
	
	print("GameActions: Resolved try_play_card action sucessfully")
	await TriggerSystem.emit(Events.CARD_PLAYED, event)
	return true
	
func try_attack(attacker: CardInstance, target: CardInstance) -> bool:
	print("GameActions: Requested try_attack action")
	if TurnController.current_phase != TurnController.Phase.BATTLE:
		return false
	
	#Do rest of attack action logic
	return true

func draw_cards(player: Player, amount: int) -> void:
	print("GameActions: Requested draw_cards action")
	for i in amount:
		if player.deck.is_empty():
			return #Deck out
		var card: CardInstance = player.deck.pop_back()
		await ZoneManager.move_to(card, Zone.Type.HAND, ZoneChangeEvent.Reason.DRAW)
