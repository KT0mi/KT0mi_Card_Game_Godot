class_name ModifierEvent extends CancellableEvent

var target : CardInstance
var source : CardInstance
var modifier : Modifier

func _init(t: CardInstance, s: CardInstance, mod: Modifier) -> void:
	target = t
	source = s
	modifier = mod
