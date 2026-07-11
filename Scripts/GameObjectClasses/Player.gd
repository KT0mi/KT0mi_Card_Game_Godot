class_name Player

const ARENA_MAX_SIZE := 3

var player_name: String
var hand: Array[CardInstance] = []
var arena: Array[CardInstance] = []
var deck: Array[CardInstance] = []
var graveyard: Array[CardInstance] = []
var player_zone: Array[CardInstance] = []

func _init(name: String) -> void:
	player_name = name

#Return  direct reference to card instance array for a player's zone
func zone_array(zone: Zone.Type) -> Array[CardInstance]:
	match zone:
		Zone.Type.HAND: return hand
		Zone.Type.ARENA: return arena
		Zone.Type.DECK: return deck
		Zone.Type.GRAVEYARD: return graveyard
		Zone.Type.PLAYER: return player_zone
		_: return []

func all_cards() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	result.append_array(hand)
	result.append_array(arena)
	result.append_array(graveyard)
	result.append(player_zone)
	return result
	
func can_add_to_arena() -> bool:
	return arena.size() < ARENA_MAX_SIZE
