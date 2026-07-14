extends Node2D
######################################
######## PLACEHOLDER SCRIPT ##########
######################################
#Since this is a connection between game logic and scene control, spawning, and debugging
#this must later be refactored into smaller scripts and if possible passing as must logic 
#into autoloaders

#This sets up a match by building decks, spawning cards, cardholders
#sets up a minimal debug ui

const CARD_SCENE := preload("res://Scenes/Card.tscn")

@export var player_one_deck: DeckData
@export var player_two_deck: DeckData

const FALLBACK_DECK_IDS: Array[StringName] = [
	&"test_creature", &"test_creature", &"test_creature", &"test_creature",
	&"test_spell", &"test_spell", &"test_spell", &"test_spell"
]

var _canvas: CanvasLayer
var _phase_label : Label
var _zones_label : Label
var _choice_panel: VBoxContainer
var _choice_checkboxes: Dictionary = {}  # option -> CheckBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_build_debug_ui()
	ChoiceManager.choice_requested.connect(_on_choice_requested)
	TurnController.phase_changed.connect(func(_phase, _player) -> void: _refresh_ui())
	await _setup_players()
	await TurnController.start_match()
	_refresh_ui()

func _setup_players() -> void:
	GameState.local_player = GameState.player_one #Default value for testing
	
	for entry in [
		{player = GameState.player_one, deck = player_one_deck},
		{player = GameState.player_two, deck = player_two_deck},
	]:
		var player: Player = entry.player
		var deck: DeckData = entry.deck
		
		var instances: Array[CardInstance] = build_deck(player, deck)
		for instance in instances:
			_spawn_card_node(instance)
			await ZoneManager.move_to(instance, Zone.Type.DECK, ZoneChangeEvent.Reason.MANUAL)
 
		# Give the player their face card. This arguably belongs in
		# RulesEngine.setup_match() long-term, alongside the special-card
		# rule it already has -- kept here for now so the test harness
		# stays self-contained and doesn't presume that decision for you.
		var face := CardFactory.create_instance(&"test_player_card", player)
		face.definition.card_name = "You" if player == GameState.local_player else "Opponent"
		_spawn_card_node(face)
		await ZoneManager.move_to(face, Zone.Type.PLAYER, ZoneChangeEvent.Reason.MANUAL)

func build_deck(player: Player, deck: DeckData) -> Array[CardInstance]:
	if deck:
		return CardFactory.build_deck(deck, player)
	return CardFactory.build_deck_from_ids(FALLBACK_DECK_IDS, player)
 
func _spawn_card_node(instance: CardInstance) -> Card:
	var node: Card = CARD_SCENE.instantiate()
	add_child(node)
	node.bind(instance)
	return node
 
func _build_debug_ui() -> void:
	_canvas = CanvasLayer.new()
	add_child(_canvas)
 
	var vbox := VBoxContainer.new()
	vbox.position = Vector2(20, 20)
	_canvas.add_child(vbox)
 
	_phase_label = Label.new()
	vbox.add_child(_phase_label)
 
	_zones_label = Label.new()
	vbox.add_child(_zones_label)
 
	var advance_button := Button.new()
	advance_button.text = "Advance phase"
	advance_button.pressed.connect(_on_advance_pressed)
	vbox.add_child(advance_button)
	
	var reveal_checkbox := CheckBox.new()
	reveal_checkbox.text = "Reveal hidden cards (debug)"
	reveal_checkbox.toggled.connect(func(pressed: bool): DebugSettings.reveal_hidden_cards = pressed)
	vbox.add_child(reveal_checkbox)
	
	var show_all_choices_checkbox := CheckBox.new()
	show_all_choices_checkbox.text = "Show all choices, incl. AI's (debug)"
	show_all_choices_checkbox.toggled.connect(func(pressed: bool): DebugSettings.show_all_choices_in_debug_ui = pressed)
	vbox.add_child(show_all_choices_checkbox)


func _on_advance_pressed() -> void:
	await TurnController.advance_phase()
	_refresh_ui()
 
func _refresh_ui() -> void:
	_phase_label.text = "Turn %d -- %s's %s phase" % [
		TurnController.turn_counter,
		TurnController.current_player.player_name,
		TurnController.Phase.keys()[TurnController.current_phase],
	]
	_zones_label.text = "P1  hand:%d  arena:%d  deck:%d  graveyard:%d\nP2  hand:%d  arena:%d  deck:%d  graveyard:%d" % [
		GameState.player_one.hand.size(), GameState.player_one.arena.size(),
		GameState.player_one.deck.size(), GameState.player_one.graveyard.size(),
		GameState.player_two.hand.size(), GameState.player_two.arena.size(),
		GameState.player_two.deck.size(), GameState.player_two.graveyard.size(),
	]

func _on_choice_requested(req: ChoiceRequest) -> void:
	if req.requesting_player != GameState.local_player and \
	not DebugSettings.show_all_choices_in_debug_ui:
		return
	
	if _choice_panel:
		_choice_panel.queue_free()
	_choice_checkboxes.clear()
	
	_choice_panel = VBoxContainer.new()
	_choice_panel.position = Vector2(20, 220)
	_canvas.add_child(_choice_panel)
	
	var label := Label.new()
	label.text = "Player %s: %s (Pick %d-%d)" % [
		"1" if req.requesting_player == GameState.player_one else "2",
		req.prompt,
		req.min_count,
		req.max_count]
	_choice_panel.add_child(label)
	
	for option in req.options:
		var cb := CheckBox.new()
		cb.text = _describe_option(option)
		cb.toggled.connect(func(pressed: bool): _on_option_toggled(option, pressed))
		_choice_panel.add_child(cb)
		_choice_checkboxes[option] = cb
		
	var confirm := Button.new()
	confirm.text = "Confirm choice"
	confirm.pressed.connect(_on_choice_confirmed)
	_choice_panel.add_child(confirm)

func _on_option_toggled(option, pressed: bool) -> void:
	if option is CardInstance:
		var node := CardViewManager.card_node_for(option)
		if node:
			node.set_selected(pressed)

func _on_choice_confirmed() -> void:
	var selected: Array = []
	for option in _choice_checkboxes:
		if _choice_checkboxes[option].button_pressed:
			selected.append(option)
		if option is CardInstance:
			var node := CardViewManager.card_node_for(option)
			if node:
				node.set_selected(false)
	
	#Save reference to current choice panel
	var panel_to_close := _choice_panel
	
	var submited:= ChoiceManager.submit(selected)
	
	if submited:
		if panel_to_close:
			panel_to_close.queue_free()
		
		#Only clear the shared reference if nothing newer has already
		#taken its place -- otherwise this would null out the reference
		#to the new panel that's now legitimately showing.
		if _choice_panel == panel_to_close:
			_choice_panel = null
		_refresh_ui()


func _describe_option(option) -> String:
	if option is CardInstance:
		return option.definition.card_name
	return str(option)
