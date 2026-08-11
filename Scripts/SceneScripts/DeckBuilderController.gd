extends Control

const CARD_SCENE := preload("res://Scenes/DeckBuilderCard.tscn")
const MAX_COPIES := 4

@onready var available_list : VBoxContainer = $AvailablePanel/AvailableList
@onready var deck_list : VBoxContainer = $DeckPanel/DeckList
@onready var count_label : Label = $CountLabel
@onready var deck_name_edit : LineEdit = $DeckNameEdit
@onready var save_button : Button = $SaveButton

var working_deck: Dictionary = {}        # StringName -> int
var _available_entries: Dictionary = {}  # StringName -> DeckBuilderCard
var _deck_entries: Dictionary = {}       # StringName -> DeckBuilderCard
var _editing_deck_id: String = ""        # "" means new deck

func _ready() -> void:
	_populate_available()
	save_button.pressed.connect(_on_save_pressed)

## --- Populating the Available panel, grouped by set -------------------

func _populate_available() -> void:
	var grouped := CardDatabase.get_definitions_grouped_by_set()
	var set_ids := grouped.keys()
	set_ids.sort()

	for set_id in set_ids:
		if set_id == &"test_set": continue
		_add_set_header(available_list, set_id)
		var flow := _add_flow_row(available_list)
		for def in grouped[set_id]:
			var entry := _instantiate_entry(flow, def, DeckBuilderCard.Context.AVAILABLE)
			entry.add_requested.connect(_on_add)
			_available_entries[def.id] = entry
			_refresh_entry(def.id)

func _add_set_header(parent: VBoxContainer, set_id: StringName) -> void:
	var label := Label.new()
	label.text = String(set_id).capitalize()
	label.add_theme_font_size_override("font_size", 22)
	parent.add_child(label)

func _add_flow_row(parent: VBoxContainer) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 10)
	flow.add_theme_constant_override("v_separation", 10)
	parent.add_child(flow)
	return flow

func _instantiate_entry(parent: Node, def: CardDefinition, context: DeckBuilderCard.Context) -> DeckBuilderCard:
	var entry : DeckBuilderCard = CARD_SCENE.instantiate()
	parent.add_child(entry)   # add_child BEFORE setup() -- @onready vars need the node in the tree first
	entry.setup(def)
	entry.set_context(context)
	return entry

## --- Add / remove ------------------------------------------------------

func _max_copies_for(def: CardDefinition) -> int:
	return 1 if def.is_special else MAX_COPIES

func _special_count() -> int:
	var total := 0
	for id in working_deck:
		if CardDatabase.get_definition(id).is_special:
			total += working_deck[id]
	return total

func _can_add(def: CardDefinition, count: int, max_copies: int) -> bool:
	if count >= max_copies:
		return false
	if def.is_special and count == 0 and _special_count() >= 1:
		return false  # a different special card is already in the deck
	return true

func _on_add(id: StringName) -> void:
	var def := CardDatabase.get_definition(id)
	var count: int = working_deck.get(id, 0)
	if not _can_add(def, count, _max_copies_for(def)):
		return

	working_deck[id] = count + 1
	_refresh_entry(id)
	if def.is_special:
		_refresh_all_special_entries()  # this add may have just locked out other specials

func _on_remove(id: StringName) -> void:
	var def := CardDatabase.get_definition(id)
	var count: int = working_deck.get(id, 0)
	if count <= 0:
		return

	count -= 1
	if count == 0:
		working_deck.erase(id)
	else:
		working_deck[id] = count
	_refresh_entry(id)
	if def.is_special:
		_refresh_all_special_entries()  # removing it may have just unlocked other specials

func _refresh_all_special_entries() -> void:
	for id in _available_entries:
		if CardDatabase.get_definition(id).is_special:
			_refresh_entry(id)

## --- Syncing one card's visual state across both panels -----------------

func _refresh_entry(id: StringName) -> void:
	var def := CardDatabase.get_definition(id)
	var count: int = working_deck.get(id, 0)
	var max_copies := _max_copies_for(def)
	var can_add := _can_add(def, count, max_copies)
	var can_remove := count > 0

	_available_entries[id].refresh_state(count, max_copies, can_add, can_remove)

	if count > 0 and not _deck_entries.has(id):
		var entry := _instantiate_entry(deck_list, def, DeckBuilderCard.Context.DECK)
		entry.remove_requested.connect(_on_remove)
		_deck_entries[id] = entry
	elif count == 0 and _deck_entries.has(id):
		_deck_entries[id].queue_free()
		_deck_entries.erase(id)

	if _deck_entries.has(id):
		_deck_entries[id].refresh_state(count, max_copies, can_add, can_remove)

	_update_count_label()

func _update_count_label() -> void:
	var total := 0
	for c in working_deck.values():
		total += c
	count_label.text = "%d cards" % total

## --- Save / load ---------------------------------------------------------

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
