class_name Ability extends RefCounted

var trigger: StringName
var effect: Callable
var condition: Callable
 
## Most abilities only work while their card is in hand or arena. Set this
## true for the rare graveyard-triggered ability (e.g. a card that reacts
## from the graveyard itself) -- see GameState.is_ability_active().
var active_in_graveyard: bool = false
 
func _init(t: StringName, e: Callable,
		c: Callable = func(_card, _event): return true,
		graveyard: bool = false) -> void:
	trigger = t
	effect = e
	condition = c
	active_in_graveyard = graveyard
 
func resolve(card: CardInstance, event: GameEvent) -> void:
	await effect.call(card, event)
