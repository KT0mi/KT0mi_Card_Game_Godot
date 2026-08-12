class_name SummonEvent extends CancellableEvent

var player : Player
var card_id : StringName

func _init(p: Player, id : StringName) -> void:
	player = p
	card_id = id
