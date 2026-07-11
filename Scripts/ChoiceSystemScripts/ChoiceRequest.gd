class_name ChoiceRequest extends RefCounted
#Describe one pending choice: whats is being asked, the legal options
# how many must be picked.

signal resolved(selected: Array)

var prompt: String
var options: Array
var min_count: int
var max_count: int

func _init(p: String, o: Array, min_c: int, max_c: int) -> void:
	prompt = p
	options = o
	min_count = min_c
	max_count = max_c

func is_valid(selected: Array) -> bool:
	if selected.size() < min_count or selected.size() > max_count:
		return false
	for item in selected:
		if item not in options:
			return false
	return true
