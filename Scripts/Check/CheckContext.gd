class_name CheckContext extends RefCounted

##Every Check carries the context of the card this check is being evaluated for.
var card: CardInstance

func _init(c: CardInstance) -> void:
	card = c
