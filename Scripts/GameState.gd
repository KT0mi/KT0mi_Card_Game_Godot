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

func all_player_cards() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	result.append_array(player_one.all_cards())
	result.append_array(player_two.all_cards())
	return result

func all_cards_in_target_areas() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	result.append_array(player_one.arena())
	result.append_array(player_one.player_zone)
	result.append_array(player_two.arena())
	result.append_array(player_two.player_zone)
	return result

func all_cards_in_arena() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	result.append_array(player_one.arena())
	result.append_array(player_two.arena())
	return result

func all_visible_cards() -> Array[CardInstance]:
	var result : Array[CardInstance] = []
	for p in players():
		result.append_array(p.hand)
		result.append_array(p.player_zone)
		result.append_array(p.arena())
		result.append_array(p.spellbook)
	return result

func all_cards_in_play() -> Array[CardInstance]:
	var result : Array[CardInstance] = []
	for p in players():
		result.append_array(p.player_zone)
		result.append_array(p.arena())
		result.append_array(p.spellbook)
	return result

func is_ability_active(card: CardInstance, ability: Ability) -> bool:
	if card.current_zone == Zone.Type.GRAVEYARD:
		return ability.active_in_graveyard
	return card.current_zone in [Zone.Type.ARENA, Zone.Type.PLAYER, Zone.Type.SPELLBOOK]
	
## Continuous effects never act from the graveyard -- there's no card text
## in this game (yet) for "while this is in your graveyard, ..." as a
## standing condition, only as reactive Abilities, so unlike is_ability_active
## there's no active_in_graveyard escape hatch here. If that ever changes,
## add one the same way Ability did rather than special-casing it in CheckSystem.
func is_continuous_source_active(card: CardInstance) -> bool:
	return card.current_zone in [Zone.Type.ARENA, Zone.Type.PLAYER, Zone.Type.SPELLBOOK]
 
## Monotonic counter used to order SET-layer ContinuousEffects ("last one
## established wins") -- see CardInstance.continuous_since and
## ZoneManager.move_to, which is the only place that stamps it. Board-array
## order isn't reliable for this: a card's position in player.all_cards()
## reflects zone/creation order, not when it most recently became an
## active continuous-effect source.
var _timestamp: int = 0
func next_timestamp() -> int:
	_timestamp += 1
	return _timestamp
