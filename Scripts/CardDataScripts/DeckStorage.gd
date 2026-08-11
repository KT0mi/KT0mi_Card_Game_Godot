# Scripts/DeckStorage.gd
extends Node
##Autoload

const SAVE_DIR := "user://decks/"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_deck(deck: DeckData) -> bool:
	if deck.id == "":
		deck.id = _generate_id()

	var path := SAVE_DIR + deck.id + ".tres"
	var err := ResourceSaver.save(deck, path)
	if err != OK:
		push_warning("DeckStorage: failed to save deck '%s' (error %d)" % [deck.deck_name, err])
		return false
	return true

func load_deck(id: String) -> DeckData:
	var path := SAVE_DIR + id + ".tres"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as DeckData

func list_saved_decks() -> Array[DeckData]:
	var result: Array[DeckData] = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return result

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.ends_with(".tres"):
			var deck := load(SAVE_DIR + entry) as DeckData
			if deck:
				result.append(deck)
		entry = dir.get_next()
	dir.list_dir_end()
	return result

func delete_deck(id: String) -> void:
	var path := SAVE_DIR + id + ".tres"
	if ResourceLoader.exists(path):
		DirAccess.remove_absolute(path)

func _generate_id() -> String:
	return "%d_%04d" % [Time.get_unix_time_from_system(), randi() % 10000]
	
func is_deck_valid(deck: DeckData) -> bool:
	for id in deck.card_ids:
		if not CardDatabase.has_definition(id):
			push_warning("DeckStorage: deck '%s' references unknown card '%s'" % [deck.deck_name, id])
			return false
	return true
