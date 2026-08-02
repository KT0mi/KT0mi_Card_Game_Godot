class_name StatModifer extends Modifier

func apply(stat : int) -> int:
	return effect.call(stat)
