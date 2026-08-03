class_name ChoiceRequest extends RefCounted
#Describe one pending choice: whats is being asked, the legal options
# how many must be picked.

signal resolved(selected: Array)

var prompt: String
var options: Array
var min_count: int
var max_count: int
var requesting_player: Player
var tag : StringName

func _init(p: String, o: Array, min_c: int, max_c: int, rp: Player = null, t = &"") -> void:
	prompt = p
	options = o
	min_count = min_c
	max_count = max_c
	requesting_player = rp
	tag = t

func is_valid(selected: Array) -> bool:
	if selected.size() < min_count or selected.size() > max_count:
		return false
	for item in selected:
		if item not in options:
			return false
	return true
