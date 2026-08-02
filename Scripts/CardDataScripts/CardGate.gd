class_name CardGate extends Resource

enum GateType {NONE, LESS_THAN, GREATER_THAN, INTERVAL}

var gate_type: GateType
var value: int #Used by LESS_THAN and GREATER_THAN
var lower_bound: int #Used by INTERVAL
var upper_bound: int #Used by INTERVAL

func _init(
	g: GateType,
	v: int = 0,
	lb: int = 0,
	ub: int = 0
		) -> void:
	gate_type = g
	value = v
	lower_bound = lb
	upper_bound = ub

func is_playable(against : int) -> bool:
	match gate_type:
		GateType.NONE:
			return true
		GateType.LESS_THAN:
			print("CardGate: Checking gate of %d against value of %d" % [value, against])
			return against <= value
		GateType.GREATER_THAN:
			print("CardGate: Checking gate of %d against value of %d" % [value, against])
			return against >= value
		GateType.INTERVAL:
			print("CardGate: Checking gate of %d-%d against value of %d" % [lower_bound, upper_bound, against])
			return against >= lower_bound and against <= upper_bound
		_:
			return true

## COMMON CASE USES
static func BasicGate(value : int) -> CardGate:
	return CardGate.new(GateType.LESS_THAN, value)
