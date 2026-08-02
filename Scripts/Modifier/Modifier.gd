class_name Modifier extends RefCounted

var effect : Callable
var source : CardInstance
var label : String

func _init(
	e : Callable,
	src : CardInstance = null,
	lbl : String = ""
	) -> void:
	effect = e
	source = src
	label = lbl
