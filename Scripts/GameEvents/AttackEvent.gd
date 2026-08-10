class_name AttackEvent extends CancellableEvent

var attacker: CardInstance
var target: CardInstance
var redirected: bool = false #set true whenever a card redirects the target of this event
var locked: bool = false #Checked before redirecting, if true, returns false

func _init(a: CardInstance, t: CardInstance) -> void:
	attacker = a
	target = t

func redirect_target(new_target: CardInstance, source: CardInstance) -> bool:
	if not locked:
		target = new_target
		return true
	return false
