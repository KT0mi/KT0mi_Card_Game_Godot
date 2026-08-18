extends Node
##Autoload

#Anything that may change dealt damage goes through here
#Modifiers are callable(target, amount) -> int

signal change_card_endurance(card : CardInstance)

##Animation Signals
signal effect_damage_dealt(target: CardInstance, source: CardInstance, amount: int)

func apply_damage(target: CardInstance, amount: int, source: CardInstance, reason : DamageEvent.Reason = DamageEvent.Reason.CARD_EFFECT) -> void:
	var event:= DamageEvent.new(target, amount, source, reason)
	await TriggerSystem.emit(Events.DAMAGE_REQUEST, event)
	
	if event.cancelled:
		return
	
	var actual_target := event.target
	
	actual_target.current_endurance -= event.amount
	change_card_endurance.emit(actual_target)
	
	match event.reason:
		DamageEvent.Reason.STATE:
			pass
		DamageEvent.Reason.CARD_EFFECT:
			effect_damage_dealt.emit(actual_target, source, event.amount)
	
	##DEBUG: This is to inform ui objects that player card health has changed
	if actual_target.current_zone == Zone.Type.PLAYER:
		for c in actual_target.owner.hand:
			change_card_endurance.emit(c)
	
	RulesEngine.check_state_based_actions()
	await TriggerSystem.emit(Events.DAMAGE_RESOLVED, event)
