extends Node
##Autoload

#Anything that may change dealt damage goes through here
#Modifiers are callable(target, amount) -> int

signal change_card_endurance(card : CardInstance)

func apply_damage(target: CardInstance, amount: int, source: CardInstance) -> void:
	var event:= DamageEvent.new(target, amount, source)
	await TriggerSystem.emit(Events.DAMAGE_REQUEST, event)
	
	if event.cancelled:
		return
	
	target.current_endurance -= event.amount
	change_card_endurance.emit(target)
	await TriggerSystem.emit(Events.DAMAGE_RESOLVED, event)
