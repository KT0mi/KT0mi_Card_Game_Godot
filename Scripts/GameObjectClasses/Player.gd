class_name Player

const ARENA_LANES := 3

var player_name: String
var hand: Array[CardInstance] = []
var arena_lanes: Array[CardInstance] = [null, null, null]
var deck: Array[CardInstance] = []
var graveyard: Array[CardInstance] = []
var player_zone: Array[CardInstance] = []
var spellbook: Array[CardInstance] = []

func _init(name: String) -> void:
	player_name = name

#Return direct reference to card instance array for a player's zone
func zone_array(zone: Zone.Type) -> Array[CardInstance]:
	match zone:
		Zone.Type.HAND: return hand
		Zone.Type.ARENA: return arena()
		Zone.Type.DECK: return deck
		Zone.Type.GRAVEYARD: return graveyard
		Zone.Type.PLAYER: return player_zone
		Zone.Type.SPELLBOOK: return spellbook
		_: return []

func all_cards() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	#result.append_array(hand)
	result.append_array(arena())
	result.append_array(graveyard)
	result.append_array(player_zone)
	result.append_array(spellbook)
	return result

func arena() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for c in arena_lanes:
		if c != null:
			result.append(c)
	return result

func is_lane_open(lane: int) -> bool:
	return lane >= 0 and lane < ARENA_LANES and arena_lanes[lane] == null
	
func get_player_card() -> CardInstance:
	var card : CardInstance = player_zone[0]
	if card == null:
		return null
	return card
