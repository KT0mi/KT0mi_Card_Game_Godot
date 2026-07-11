class_name DamageEvent extends GameEvent
#Not cancellable - by the time this fires, damage already happened.
#To intecept damage, go through DamagePipeline

var target: CardInstance
var amount: int

func _init(t: CardInstance, a: int) -> void:
	target = t
	amount = a
