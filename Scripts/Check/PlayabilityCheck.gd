class_name PlayabilityCheck extends CheckContext

enum Requirement {ACTIVE_PLAYER,IN_HAND,PLAY_PHASE,GATE,LANE_OPEN}

var requirement: Requirement
var lane : int

func _init(c: CardInstance, req: Requirement, l: int = -1) -> void:
	super._init(c)
	requirement = req
	lane = 1
