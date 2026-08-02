extends Node
##Autoload

#This holds all gameplay VERBS -> Game actions that may be performed by the
#pure game logic or the cards themselves
#Action shape: check phase legally -> emit a cancellable "_request" event ->
# bail if cancelled -> perform the state change -> emit the "resolved" notification.

signal card_stat_changed(card: CardInstance)

func try_play_card(player: Player, card: CardInstance) -> bool:
	print("GameActions: Requested try_play_card action")
	if card.current_zone != Zone.Type.HAND:
		print("GameActions: Failed try_play_card action. Reason: Card is not in hand")
		return false
	
	if TurnController.current_phase != TurnController.Phase.PLAY:
		print("GameActions: Failed try_play_card action. Reason: Not in play phase")
		return false
		
	if TurnController.current_player != player:
		print("GameActions: Failed try_play_card action: Reason: Not active player")
		return false
	
	if !card.is_playable(player.player_zone[0].get_endurance()):
		print("GameActions: Failed try_play_card action: Reason: Card gated")
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
		if card.is_spell():
			print("GameActions: try_play_card: Resolving instant spell effect of %s." % card.definition.id)
			await (card.definition as SpellCardDefinition).resolve_effect(card, event)
			var def : SpellCardDefinition = card.definition
			if def.cast_type == SpellCardDefinition.CastType.INSTANT:
				await ZoneManager.move_to(card, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.PLAY)
			else:
				await ZoneManager.move_to(card, Zone.Type.SPELLBOOK, ZoneChangeEvent.Reason.PLAY)
	
	print("GameActions: Resolved try_play_card action sucessfully")
	await TriggerSystem.emit(Events.CARD_PLAYED, event)
	return true
	
func try_kill_card(card : CardInstance) -> bool:
	print("GameActions: Requested try_kill_card action")
	
	var event := DeathEvent.new(card)
	await TriggerSystem.emit(Events.KILL_REQUEST, event)
	if event.cancelled:
		print("GameActions: Failed try_kill_card action. Reason: Request intercepted")
		return false
		
	#Hook point to change death mechanic
	await ZoneManager.move_to(card, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.DEATH)
	
	print("GameActions: Resolved try_kill_card action sucessfully")
	await TriggerSystem.emit(Events.KILL_RESOLVED, event)
	return true

func try_attack(attacker: CardInstance, target: CardInstance) -> bool:
	print("GameActions: Requested try_attack action")
	
	var event := AttackEvent.new(attacker, target)
	await TriggerSystem.emit(Events.ATTACK_REQUEST, event)
	if event.cancelled:
		print("GameActions: Failed try_attack action. Reason: Request intercepted")
		return false
	
	#Hook point for target redirection - not implemented
	
	await DamagePipeline.apply_damage(event.target, attacker.current_attack, attacker)
	
	print("GameActions: Resolved try_attack action sucessfully")
	await TriggerSystem.emit(Events.ATTACK_RESOLVED, event)
	return true

func draw_cards(player: Player, amount: int) -> void:
	print("GameActions: Requested draw_cards action for player %s of %d cards" % ["1" if player == GameState.player_one else "2", amount])
	for i in amount:
		if player.deck.is_empty():
			return #Deck out
		var card: CardInstance = player.deck.pop_back()
		await ZoneManager.move_to(card, Zone.Type.HAND, ZoneChangeEvent.Reason.DRAW)

func try_modify_attack(target: CardInstance, mod : StatModifer) -> bool:
	print("GameActions: Requested try_modify_attack action")
	var event := ModifierEvent.new(target, mod.source, mod)
	await TriggerSystem.emit(Events.MODIFY_ATTACK_REQUEST, event)
	if event.cancelled:
		print("GameActions: Failed try_modify_attack action. Reason: Request intercepted")
		return false
	
	target.attack_modifiers.append(mod)
	card_stat_changed.emit(target)
	print("GameActions: Resolved try_modify_attack action sucessfully.")
	await TriggerSystem.emit(Events.MODIFY_ATTACK_RESOLVE, event)
	return true

func try_modify_endurance(target: CardInstance, mod : StatModifer) -> bool:
	print("GameActions: Requested try_modify_endurance action")
	var event := ModifierEvent.new(target, mod.source, mod)
	await TriggerSystem.emit(Events.MODIFY_ENDURANCE_REQUEST, event)
	if event.cancelled:
		print("GameActions: Failed try_modify_endurance action. Reason: Request intercepted")
		return false
	
	target.endurance_modifiers.append(mod)
	card_stat_changed.emit(target)
	print("GameActions: Resolved try_modify_endurance action sucessfully.")
	await TriggerSystem.emit(Events.MODIFY_ENDURANCE_REQUEST, event)
	return true

func try_modify_gate(target: CardInstance, mod : GateModifier) -> bool:
	print("GameActions: Requested try_modify_gate action")
	var event := ModifierEvent.new(target, mod.source, mod)
	await TriggerSystem.emit(Events.MODIFY_GATE_REQUEST, event)
	if event.cancelled:
		print("GameActions: Failed try_modify_gate action. Reason: Request intercepted")
		return false
	
	target.gate_modifiers.append(mod)
	card_stat_changed.emit(target)
	print("GameActions: Resolved try_modify_gate action sucessfully.")
	await TriggerSystem.emit(Events.MODIFY_GATE_RESOLVE, event)
	return true
