extends Control

@onready var duel_button : Button = $DuelButton
@onready var deck_builder_button : Button = $DeckBuilderButton
@onready var deck_selector : ScrollContainer = $DeckSelector

const DUEL_SCENE := "res://Scenes/TestScene.tscn"
const DECK_BUILDER_SCENE := "res://Scenes/DeckBuilder.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	duel_button.pressed.connect(_on_duel_pressed)
	deck_builder_button.pressed.connect(_on_deck_builder_pressed)
	deck_selector.choose_deck.connect(func(id): StateData.chosen_deck = id)

func _on_duel_pressed() -> void:
	get_tree().change_scene_to_file(DUEL_SCENE)
	
func _on_deck_builder_pressed() -> void:
	get_tree().change_scene_to_file(DECK_BUILDER_SCENE)
