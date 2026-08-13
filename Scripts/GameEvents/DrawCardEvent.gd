class_name DrawCardEvent extends GameEvent

enum Reason { TURN, EFFECT}

var player : Player
var amount : int
var reason : Reason

func _init(p : Player, a : int, r : Reason) -> void:
	player = p
	amount = a
	reason = r
