class_name PlayCardEvent extends CancellableEvent
 
var player: Player
var card: CardInstance
 
func _init(p: Player, c: CardInstance) -> void:
	player = p
	card = c
 
