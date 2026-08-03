class_name StatModifer extends Modifier

func apply(stat : int) -> int:
	return effect.call(stat)

##Comon case
static func delta(amount: int, src: CardInstance = null, lbl = "") -> StatModifer:
	return StatModifer.new(func(v: int) -> int: return v + amount, src, lbl)
