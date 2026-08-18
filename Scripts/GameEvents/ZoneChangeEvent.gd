class_name ZoneChangeEvent extends GameEvent
## Not cancellable -- by the time this fires the move has already happened.
## If you need to PREVENT a card entering/leaving a zone, that has to be a
## CancellableEvent fired before the move (like PlayCardEvent), not this one.
 
enum Reason { DRAW, DISCARD, SACRIFICE, DEATH, PLAY, RETURN, RESOLVE, SUMMON, MANUAL }
 
var target: CardInstance
var from_zone: Zone.Type
var to_zone: Zone.Type
var reason: Reason
var lane: int
var anim_group : StringName
 
func _init(c: CardInstance, f: Zone.Type, t: Zone.Type, r: Reason, l : int = -1,g: StringName = &"") -> void:
	target = c
	from_zone = f
	to_zone = t
	reason = r
	lane = l
	anim_group = g
