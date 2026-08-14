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
		print("AttackEvent: %s redirected attack from %s to %s" % [
			source.definition.card_name,
			target.definition.card_name,
			new_target.definition.card_name
		])
		target = new_target
		redirected = true
		return true
	return false
