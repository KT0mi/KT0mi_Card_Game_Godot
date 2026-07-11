extends Node
##Autoload

#Anything that may change dealt damage goes through here
#Modifiers are callable(target, amount) -> int

func apply_damage(target: CardInstance, amount: int) -> void:
	var final_amount := amount
	
	for modifier in target.damage_modifiers.duplicate():
		final_amount = await modifier.call(target, final_amount)
		
	target.current_endurance -= final_amount
	await TriggerSystem.emit(Events.DAMAGE_DEALT, DamageEvent.new(target, final_amount))
