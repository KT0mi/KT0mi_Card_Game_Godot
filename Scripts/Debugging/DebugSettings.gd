extends Node
##AutoLoad

signal reveal_hidden_cards_changed(revealed: bool)

var reveal_hidden_cards: bool = false:
	set(value):
		reveal_hidden_cards = value
		reveal_hidden_cards_changed.emit(value)

var show_all_choices_in_debug_ui: bool = false
