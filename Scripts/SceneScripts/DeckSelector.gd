extends ScrollContainer

@onready var delete_button_icon := preload("res://Assets/Images/Test/trash_icon.png")
@onready var deck_list : BoxContainer = $DeckList

signal choose_deck(id : String)

func _ready() -> void:
	_populate_deck_list()
	
func _populate_deck_list() -> void:
	var decks := DeckStorage.list_saved_decks()
	
	for deck in decks:
		var deck_box : HBoxContainer = HBoxContainer.new()
		
		var i : int = 0
		var deck_button : Button = Button.new()
		deck_button.size = Vector2(124, 124)
		if deck.deck_name != "":
			deck_button.text = deck.deck_name 
		else: 
			deck_button.text = "Untitled Deck %d" % i
			i += 1
		deck_button.pressed.connect(func(): choose_deck.emit(deck.id))
		
		var delete_button : Button = Button.new()
		delete_button.icon = delete_button_icon
		delete_button.pressed.connect(_delete_button.bind(deck.id))
		
		deck_box.add_child(deck_button)
		deck_box.add_spacer(true)
		deck_box.add_child(delete_button)
		
		deck_list.add_child(deck_box)

func _delete_button(id: String) -> void:
	DeckStorage.delete_deck(id)
	_clear_deck_list()
	_populate_deck_list()

func _clear_deck_list() -> void:
	for d in deck_list.get_children():
		d.queue_free()
