class_name Modifier extends RefCounted
##A Modifier is a permanent (Default: add-only, auto-cleanup) addition to card stats
##That is stored by cards

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
