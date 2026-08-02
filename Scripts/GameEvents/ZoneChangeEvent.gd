class_name ZoneChangeEvent extends GameEvent
## Not cancellable -- by the time this fires the move has already happened.
## If you need to PREVENT a card entering/leaving a zone, that has to be a
## CancellableEvent fired before the move (like PlayCardEvent), not this one.
 
enum Reason { DRAW, DISCARD, SACRIFICE, DEATH, PLAY, RETURN, MANUAL }
 
var target: CardInstance
var from_zone: Zone.Type
var to_zone: Zone.Type
var reason: Reason
 
func _init(c: CardInstance, f: Zone.Type, t: Zone.Type, r: Reason) -> void:
	target = c
	from_zone = f
	to_zone = t
	reason = r
