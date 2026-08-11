extends Control

@onready var duel_button : Button = $DuelButton
@onready var deck_builder_button : Button = $DeckBuilderButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	duel_button.pressed.connect(_on_duel_pressed)
	deck_builder_button.pressed.connect(_on_deck_builder_pressed)

func _on_duel_pressed() -> void:
	pass
	
func _on_deck_builder_pressed() -> void:
	pass
