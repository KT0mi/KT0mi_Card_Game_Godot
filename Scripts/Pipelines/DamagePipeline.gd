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
	
	var actual_target := event.target
	
	##DEBUG: This is to inform ui objects that player card health has changed
	if actual_target.current_zone == Zone.Type.PLAYER:
		for c in actual_target.owner.hand:
			change_card_endurance.emit(c)
	
	
	actual_target.current_endurance -= event.amount
	change_card_endurance.emit(actual_target)
	RulesEngine.check_state_based_actions()
	await TriggerSystem.emit(Events.DAMAGE_RESOLVED, event)
