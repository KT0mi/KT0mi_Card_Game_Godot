class_name ContinuousEffect extends RefCounted

##A continuous effect isn't exactly triggered but simply something that is always true
##While it's source card is active. This means that ContinuousEffects don't resolve.
##ContinousEffects are consulted when asked in a synchronous way.

##Continuous effects are categorized by 
#value affected - Kind 
#layer affected - Layer

enum Kind {ATTACK, ENDURANCE, GATE, EFFECT_DAMAGE}
enum Layer {DELTA, SET, FINAL}

var kind : Kind
var layer : Layer

##Argument shape depends on kind but is always:
##(source: CardInstance, x: CardInstance) -> bool:
## x is defined by Kind
var applies_to : Callable

#(value:Variant, source : CardInstance) -> value:
var effect : Callable

func _init(k: Kind, target_predicate: Callable, e:Callable, l:Layer = Layer.DELTA) -> void:
	kind = k
	applies_to = target_predicate
	effect = e
	layer = l
