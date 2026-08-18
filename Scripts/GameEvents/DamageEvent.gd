class_name DamageEvent extends CancellableEvent

var target: CardInstance
var amount: int
var source: CardInstance

enum Reason {STATE, CARD_EFFECT, ATTACK}
var reason : Reason

var redirected: bool = false

func _init(t: CardInstance, a: int, s: CardInstance = null, r : Reason = Reason.CARD_EFFECT) -> void:
	target = t
	amount = a
	source = s
	reason = r

func redirect_target(new_target: CardInstance, source: CardInstance) -> bool:
	target = new_target
	redirected = true
	return true
