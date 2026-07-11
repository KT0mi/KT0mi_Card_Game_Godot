class_name DeathEvent extends CancellableEvent

var card : CardInstance

func _init(c : CardInstance) -> void:
	card = c
