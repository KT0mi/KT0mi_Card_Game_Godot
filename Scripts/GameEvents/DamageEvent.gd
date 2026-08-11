class_name DamageEvent extends CancellableEvent

var target: CardInstance
var amount: int
var source: CardInstance
var redirected: bool = false

func _init(t: CardInstance, a: int, s: CardInstance = null) -> void:
	target = t
	amount = a
	source = s

func redirect_target(new_target: CardInstance, source: CardInstance) -> bool:
	target = new_target
	redirected = true
	return true
