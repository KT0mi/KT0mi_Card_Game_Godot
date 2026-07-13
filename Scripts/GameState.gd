extends Node
##AutoLoad

#Data Script
#Read Only -> Used to read the current gamestate like the players, zones,
#and cards in play

var player_one: Player
var player_two: Player

#Which player object the client is playing as
var local_player: Player

func players() -> Array[Player]:
	return [player_one, player_two]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_one = Player.new("Player 1")
	player_two = Player.new("Player 2")

func opponent_of(player: Player) -> Player:
	return player_two if player == player_one else player_one

#Active-player-first resolution order for simultaneous triggers.
func turn_order() -> Array[Player]:
	var active := TurnController.current_player
	if active == null:
		return [player_one, player_two]
	return [active, opponent_of(active)]

func all_cards_in_play() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	result.append_array(player_one.all_cards())
	result.append_array(player_two.all_cards())
	return result

func all_cards_in_target_areas() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	result.append_array(player_one.arena)
	result.append_array(player_one.player_zone)
	result.append_array(player_two.arena)
	result.append_array(player_two.player_zone)
	return result
	
func is_ability_active(card: CardInstance, ability: Ability) -> bool:
	if card.current_zone == Zone.Type.GRAVEYARD:
		return ability.active_in_graveyard
	return card.current_zone in [Zone.Type.ARENA, Zone.Type.PLAYER, Zone.Type.SPELLBOOK]
