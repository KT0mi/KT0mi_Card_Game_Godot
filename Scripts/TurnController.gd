extends Node
##Autoload

#5-phase State machine

#Signal for systems that are external to game logic (UI, AI, etc.)
signal phase_changed(phase: Phase, player: Player)

enum Phase {START_TURN, DRAW, PLAY, BATTLE, END_TURN}

var turn_counter: int = 0
var current_phase: Phase = Phase.START_TURN
var current_player: Player

func round_counter() -> int:
	return ceili(turn_counter/2.0)

func start_match() -> void:
	RulesEngine.setup_match()
	current_player = GameState.player_one
	turn_counter = 1
	await _enter_phase(Phase.START_TURN)
	
func advance_phase() -> void:
	match current_phase:
		Phase.START_TURN:	await _enter_phase(Phase.DRAW)
		Phase.DRAW:			await _enter_phase(Phase.PLAY)
		Phase.PLAY:			await _enter_phase(Phase.BATTLE)
		Phase.BATTLE:		await _enter_phase(Phase.END_TURN)
		Phase.END_TURN:		await _end_turn_and_pass()

func _enter_phase(phase: Phase) -> void:
	var event := PhaseEvent.new(current_player)
	
	match phase:
		Phase.START_TURN:
			current_phase = phase
			await TriggerSystem.emit(Events.START_PHASE_START, event)
		Phase.DRAW:
			await TriggerSystem.emit(Events.START_PHASE_END, event)
			current_phase = phase
			await TriggerSystem.emit(Events.DRAW_PHASE_START, event)
			if turn_counter > 1:
				await GameActions.draw_cards(current_player, 1)
		Phase.PLAY:
			await TriggerSystem.emit(Events.DRAW_PHASE_END, event)
			current_phase = phase
			await TriggerSystem.emit(Events.PLAY_PHASE_START, event)
		Phase.BATTLE:
			await TriggerSystem.emit(Events.PLAY_PHASE_END, event)
			current_phase = phase
			await TriggerSystem.emit(Events.BATTLE_PHASE_START, event)
			await _resolve_battle_phase()
		Phase.END_TURN:
			await TriggerSystem.emit(Events.BATTLE_PHASE_END, event)
			current_phase = phase
			await TriggerSystem.emit(Events.END_PHASE_START, event)
			await RulesEngine.check_state_based_actions()
			
	phase_changed.emit(current_phase, current_player)

func _end_turn_and_pass() -> void:
	var event := PhaseEvent.new(current_player)
	await TriggerSystem.emit(Events.END_PHASE_END, event)
	
	current_player = GameState.opponent_of(current_player)
	turn_counter += 1
	await _enter_phase(Phase.START_TURN)
	

func _resolve_battle_phase() -> void:
	#If no cards in arena skip battle phase resolve
	if current_player.arena.is_empty():
		return
	
	#Prompt choice for player to choose atackers
	var attackers: Array = await ChoiceManager.request(
		"Choose attackers from arena cards",
		current_player.arena.duplicate(),
		0,
		current_player.arena.size(),
		current_player
	)
	
	#If no attackers after choice, return
	if attackers.is_empty():
		return
		
	var opponent := GameState.opponent_of(current_player)
	var face : CardInstance = opponent.player_zone[0]
	
	for attacker in attackers:
		await GameActions.try_attack(attacker, face)
