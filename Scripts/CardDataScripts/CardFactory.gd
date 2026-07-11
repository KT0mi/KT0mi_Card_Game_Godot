class_name CardFactory
#Constructing card instances from DeckData

static func create_instance(id: StringName, owner: Player) -> CardInstance:
	var def:= CardDatabase.get_definition(id)
	return CardInstance.new(def, owner)
	
#Build a full shuffled array of card instances for one player from DeckData
static func build_deck(deck_data: DeckData, owner: Player) -> Array[CardInstance]:
	return build_deck_from_ids(deck_data.card_ids, owner)

static func build_deck_from_ids(ids: Array[StringName], owner: Player) -> Array[CardInstance]:
	var instances: Array[CardInstance] = []
	for id in ids:
		instances.append(create_instance(id, owner))
	instances.shuffle()
	return instances
