extends Node
##Autoload

#Bare-minimum opponent for playtesting -- not meant to be smart, just
#competent enough that you don't have to control both seats yourself.
#Hooks the exact same public entry points a human uses (GameActions,
#ChoiceManager) rather than anything privileged, so it can never do
#something a human player couldn't do through the normal UI.

@export var ai_player_is_player_two: bool = true

func _ready() -> void:
	TurnController.phase_changed.connect(_on_phase_changed)
	ChoiceManager.choice_requested.connect(_on_choice_requested)

func _ai_player() -> Player:
	return GameState.player_two if ai_player_is_player_two else GameState.player_one

func _on_phase_changed(phase: TurnController.Phase, player: Player) -> void:
	if player != _ai_player():
		return
	if phase == TurnController.Phase.PLAY:
		await _take_play_phase_actions()

func _take_play_phase_actions() -> void:
	var ai := _ai_player()
	#No strategy at all: try every card currently in hand once, in order,
	#and just accept whatever GameActions allows or rejects (phase gating,
	#arena capacity, etc are all still enforced normally). Enough to
	#exercise the same pipeline a human dragging cards would use.
	for card in ai.hand.duplicate():
		await GameActions.try_play_card(ai, card)

func _on_choice_requested(request: ChoiceRequest) -> void:
	if request.requesting_player != _ai_player():
		return  #not the AI's decision -- leave it for the human-facing UI

	#Dumbest possible legal answer: take as many options as allowed,
	#first-available. Swap this for real evaluation whenever you actually
	#want the AI to be good -- the point right now is just keeping a match
	#moving without a human controlling both seats.
	var selected: Array = request.options.slice(0, request.max_count)
	ChoiceManager.submit(selected)
