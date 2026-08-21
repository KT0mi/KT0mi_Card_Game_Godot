class_name PlayabilityCheck extends CheckContext

enum Injectable {ACTIVE_PLAYER,IN_HAND,PLAY_PHASE,GATE,LANE_OPEN,CARD_EFFECT}

var injectable: Injectable
var lane : int

func _init(c: CardInstance, inj: Injectable, l: int = -1) -> void:
	super._init(c)
	injectable = inj
	lane = 1
