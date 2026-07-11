class_name AttackEvent extends CancellableEvent

var attacker: CardInstance
var target: CardInstance

func _init(a: CardInstance, t: CardInstance) -> void:
	attacker = a
	target = t
