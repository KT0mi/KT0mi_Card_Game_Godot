extends Control

const CARD_SCENE := preload("res://Scenes/DeckBuilderCard.tscn")
const MAX_COPIES := 4

@onready var available_list : VBoxContainer = $AvailablePanel/AvailableList
@onready var deck_list : VBoxContainer = $DeckPanel/DeckList
@onready var count_label : Label = $CountLabel
@onready var deck_name_edit : LineEdit = $DeckNameEdit
@onready var save_button : Button = $SaveButton

var working_deck: Dictionary = {}   # StringName -> int
var _available_entries: Dictionary = {}  # StringName -> DeckBuilderCardEntry
var _deck_entries: Dictionary = {}       # StringName -> DeckBuilderCardEntry
var _editing_deck_id: String = ""        # "" means new deck

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_populate_available()
	save_button.pressed.connect(_on_save_pressed)

func _populate_available() -> void:
	for def : CardDefinition in CardDatabase.get_all_definitions():
		var entry := CARD_SCENE.instantiate()
		available_list.add_child(entry)
		entry.setup(def)
		entry.add_requested.connect(_on_add)
		entry.refresh_count(0, MAX_COPIES)
		_available_entries[def.id] = entry

func _on_add(id: StringName) -> void:
	var current: int = working_deck.get(id, 0)
	if current >= MAX_COPIES:
		return
	working_deck[id] = current + 1
	_refresh_entry(id)

func _on_remove(id: StringName) -> void:
	var current: int = working_deck.get(id, 0)
	if current <= 0:
		return
	current -= 1
	if current == 0:
		working_deck.erase(id)
	else:
		working_deck[id] = current
	_refresh_entry(id)

func _refresh_entry(id: StringName) -> void:
	var count: int = working_deck.get(id, 0)

	_available_entries[id].refresh_count(count, MAX_COPIES)

	if count > 0 and not _deck_entries.has(id):
		var entry := CARD_SCENE.instantiate()
		deck_list.add_child(entry)
		entry.setup(CardDatabase.get_definition(id))
		entry.remove_requested.connect(_on_remove)
		_deck_entries[id] = entry
	elif count == 0 and _deck_entries.has(id):
		_deck_entries[id].queue_free()
		_deck_entries.erase(id)

	if _deck_entries.has(id):
		_deck_entries[id].refresh_count(count, MAX_COPIES)

	_update_count_label()

func _update_count_label() -> void:
	var total := 0
	for c in working_deck.values():
		total += c
	count_label.text = "%d cards" % total

func _on_save_pressed() -> void:
	var deck := DeckData.new()
	deck.id = _editing_deck_id
	deck.deck_name = deck_name_edit.text
	deck.card_ids = _flatten(working_deck)

	if not DeckStorage.is_deck_valid(deck):
		return  # or show an error label

	if DeckStorage.save_deck(deck):
		_editing_deck_id = deck.id  # capture generated id if this was a new deck

func _flatten(counts: Dictionary) -> Array[StringName]:
	var result: Array[StringName] = []
	for id in counts:
		for i in counts[id]:
			result.append(id)
	return result

func load_for_editing(deck: DeckData) -> void:
	_editing_deck_id = deck.id
	deck_name_edit.text = deck.deck_name
	working_deck.clear()
	for id in deck.card_ids:
		working_deck[id] = working_deck.get(id, 0) + 1
	for id in working_deck:
		_refresh_entry(id)
