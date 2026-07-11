extends Node
##Autoload

#5-phase State machine

enum Phase {START_TURN, DRAW, PLAY, BATTLE, END_TURN}

var turn_counter: int = 0
var current_phase: Phase = Phase.START_TURN
var current_player: Player

func round_counter() -> int:
	return ceili(turn_counter/2.0)

func start_match() -> void:
	RulesEngine.setup_match()
	current_player = GameState.player_one
	
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
		Phase.PLAY:
			await TriggerSystem.emit(Events.DRAW_PHASE_END, event)
			current_phase = phase
			await TriggerSystem.emit(Events.PLAY_PHASE_START, event)
		Phase.BATTLE:
			await TriggerSystem.emit(Events.PLAY_PHASE_END, event)
			current_phase = phase
			await TriggerSystem.emit(Events.BATTLE_PHASE_START, event)
		Phase.END_TURN:
			await TriggerSystem.emit(Events.BATTLE_PHASE_END, event)
			current_phase = phase
			await TriggerSystem.emit(Events.END_PHASE_START, event)
			await RulesEngine.check_state_based_actions()


func _end_turn_and_pass() -> void:
	var event := PhaseEvent.new(current_player)
	await TriggerSystem.emit(Events.END_PHASE_END, event)
	
	current_player = GameState.opponent_of(current_player)
	turn_counter += 1
	await _enter_phase(Phase.START_TURN)
