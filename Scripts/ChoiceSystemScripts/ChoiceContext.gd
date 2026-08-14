class_name ChoiceContext extends RefCounted

##What system or trigger requested this choice
enum Origin{UNKNOWN, CARD_EFFECT, BATTLE, MULLIGAN, STATE_ACTION}

##Semantics of the choice.
##(Mainly used for systems outside game logic - AI, UI, etc.)
##Organized logically and not due to any meta-rationality
##E.G. a +1/-2 card might be good on occasion but it will be categorically a debuff due to
##The negative literal value that it carries.
enum Intent{
	NONE,
	
	#Targetting
	DAMAGE, KILL, BUFF, DEBUFF, SACRIFICE, DISCARD, RETURN_TO_HAND, ATTACK_ATTACKER, ATTACK_TARGET,
	
	#Game State Choices
	BATTLE, MULLIGAN
}

var origin: Origin = Origin.UNKNOWN
var intent: Intent = Intent.NONE


## The card relevant to the choice.
##
## This does NOT mean that the card itself necessarily created the request.
##
## Examples:
## - Spell choosing a damage target -> the spell
## - Creature choosing a battle target -> the attacker
## - Mulligan -> null
var source_card: CardInstance = null

## The player responsible for the action that caused the choice.
##
## Often this is the same as ChoiceRequest.requesting_player,
## but not necessarily.
##
## Example:
## "Opponent chooses one of your creatures to destroy."
## The acting/source player and the choosing player could differ.
var source_player: Player = null

## Optional semantic value for AI/evaluation.
##
## Examples:
## Damage 3 -> amount = 3
## Heal 2 -> amount = 2
##
## Leave at 0 when irrelevant.
var amount: int = 0

func _init(
	p_origin: Origin = Origin.UNKNOWN,
	p_intent: Intent = Intent.NONE,
	p_source_card: CardInstance = null,
	p_source_player: Player = null,
	p_amount: int = 0
) -> void:
	origin = p_origin
	intent = p_intent
	source_card = p_source_card
	source_player = p_source_player
	amount = p_amount

# --- Common-Case Uses (Constructors) ----------

static func DAMAGE_EFFECT(src_card : CardInstance, a : int) -> ChoiceContext:
	var context:= ChoiceContext.new()
	
	context.origin = Origin.CARD_EFFECT
	context.intent = Intent.DAMAGE
	context.source_card = src_card
	context.source_player = src_card.owner
	context.amount = a
	
	return context

static func DISCARD_EFFECT(src_card: CardInstance, a : int = 1) -> ChoiceContext:
	var context := ChoiceContext.new()
	
	context.origin = Origin.CARD_EFFECT
	context.intent = Intent.DISCARD
	context.source_card = src_card
	context.source_player = src_card.owner
	context.amount = a
	
	return context

static func KILL_EFFECT(src_card, a : int = 1) -> ChoiceContext:
	var context := ChoiceContext.new()
	
	context.origin = Origin.CARD_EFFECT
	context.intent = Intent.KILL
	context.source_card = src_card
	context.source_player = src_card.owner
	context.amount = a
	
	return context

static func BATTLE(player: Player) -> ChoiceContext:
	var context := ChoiceContext.new()

	context.origin = Origin.BATTLE
	context.intent = Intent.BATTLE
	context.source_player = player

	return context

static func MULLIGAN(player: Player) -> ChoiceContext:
	var context := ChoiceContext.new()
	
	context.origin = Origin.MULLIGAN
	context.intent = Intent.MULLIGAN
	context.source_player = player
	
	return context
