class_name CardKeywords extends RefCounted
#This class stores StringName vars into constants for common use flags and counters
#For cards. I consider these "statuses" like "dazed" when a card is added to the arena.
#Because any card could have them since they are tied to Game State actions 
#and not specific card actions

## ------ Flags ------
const DAZED := &"dazed"

## ------ Keywords ------
const TAUNT := &"taunt"
const QUICK := &"quick"

## ------ Abilities -----

static func QUICK_ABILITY() -> Ability:
	return Ability.new(Events.END_PHASE_END, func(c,e): return, func(c,e): return false, [QUICK])

static func TAUNT_ABILITY() -> Ability:
	return Ability.new(
		Events.ATTACK_REQUEST,
		func(card, event: AttackEvent) -> void:
			event.redirect_target(card, card),
		_taunt_con,
		[TAUNT]
	)

static func _taunt_con(card : CardInstance, event: AttackEvent) -> bool:
	if event.attacker.owner == card.owner:
		return false
	if event.redirected:
		return false
	return true
