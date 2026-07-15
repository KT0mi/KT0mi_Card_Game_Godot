class_name DamageEvent extends CancellableEvent

var target: CardInstance
var amount: int
var source: CardInstance

func _init(t: CardInstance, a: int, s: CardInstance = null) -> void:
	target = t
	amount = a
	source = s
