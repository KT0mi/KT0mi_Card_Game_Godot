extends Node2D
##PLACEHOLDER SCRIPT
#This sets up a match by building decks, spawning cards, cardholders
#sets up a minimal debug ui

const CARD_SCENE := preload("res://Scenes/Card.tscn")

@export var player_one_deck: DeckData
@export var player_two_deck: DeckData

const FALLBACK_DECK_IDS: Array[StringName] = [
	&"test_creature", &"test_creature", &"test_creature", &"test_creature",
	&"test_spell", &"test_spell", &"test_spell", &"test_spell"
]

var _phase_label : Label
var _zones_label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_build_debug_ui()
	await _setup_players()
	await TurnController.start_match()
	_refresh_ui()

func _setup_players() -> void:
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
	var canvas := CanvasLayer.new()
	add_child(canvas)
 
	var vbox := VBoxContainer.new()
	vbox.position = Vector2(20, 20)
	canvas.add_child(vbox)
 
	_phase_label = Label.new()
	vbox.add_child(_phase_label)
 
	_zones_label = Label.new()
	vbox.add_child(_zones_label)
 
	var advance_button := Button.new()
	advance_button.text = "Advance phase"
	advance_button.pressed.connect(_on_advance_pressed)
	vbox.add_child(advance_button)
 
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
