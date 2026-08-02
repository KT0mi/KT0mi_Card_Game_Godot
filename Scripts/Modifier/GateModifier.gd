class_name GateModifier extends Modifier

func apply(gate : CardGate) -> CardGate:
	return effect.call(gate)
