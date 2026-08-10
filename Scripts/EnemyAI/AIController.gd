extends Node
##Autoload

#Bare-minimum opponent for playtesting -- not meant to be smart, just
#competent enough that you don't have to control both seats yourself.
#Hooks the exact same public entry points a human uses (GameActions,
#ChoiceManager) rather than anything privileged, so it can never do
#something a human player couldn't do through the normal UI.

@export var ai_player_is_player_two: bool = true
@export var action_delay: float = 0.6
@export var phase_delay: float = 1.0

func _ready() -> void:
	TurnController.phase_changed.connect(_on_phase_changed)
	ChoiceManager.choice_requested.connect(_on_choice_requested)

func _ai_player() -> Player:
	return GameState.player_two if ai_player_is_player_two else GameState.player_one

func _think() -> void:
	await get_tree().create_timer(action_delay).timeout

func _on_phase_changed(phase: TurnController.Phase, player: Player) -> void:
	if player != _ai_player():
		return
	if phase == TurnController.Phase.PLAY:
		await _take_play_phase_actions()
		
	await get_tree().create_timer(phase_delay).timeout
	await TurnController.advance_phase()

func _take_play_phase_actions() -> void:
	var ai := _ai_player()
	#No strategy at all: try every card currently in hand once, in order,
	#and just accept whatever GameActions allows or rejects.
	for card:CardInstance in ai.hand.duplicate():
		if card.is_creature():
			for i in ai.ARENA_LANES-1:
				var successful := await GameActions.try_play_card(ai, card, i) 
				if successful:
					break
		await GameActions.try_play_card(ai, card)
		await _think()

func _on_choice_requested(request: ChoiceRequest) -> void:
	if request.requesting_player != _ai_player():
		return  #not the AI's decision -- leave it for the human-facing UI
	
	await _think()
	
	var selected: Array = _choose(request)
	ChoiceManager.submit(selected)

func _choose(request: ChoiceRequest) -> Array:
	match request.tag:
		Events.BATTLE_TAG:
			#take as many options as allowed
			var selected: Array = request.options.slice(0, request.max_count)
			return selected
		_:
			#take as many options as allowed
			var selected: Array = request.options.slice(0, request.max_count)
			return selected
