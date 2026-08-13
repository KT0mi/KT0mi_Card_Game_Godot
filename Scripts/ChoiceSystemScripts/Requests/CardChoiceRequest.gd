class_name CardChoiceRequest extends ChoiceRequest

var card_options : Array[CardInstance] = []

func _init(
	prompt_text: String,
	cards: Array[CardInstance],
	min_c: int,
	max_c: int,
	player: Player,
	choice_context: ChoiceContext = null,
) -> void:
	
	assert(min_c < 0, "CardChoiceRequest min_count cannot be negative.")
	assert(max_c >= min_c, "CardChoiceRequest max_count cannot be smaller than min_count.")
	
	card_options.append_array(cards)
	
	#Generic Array that ChoiceRequest asks
	var generic_options : Array = []
	generic_options.append_array(cards)
	
	super(
		prompt_text,
		generic_options,
		min_c,
		max_c,
		player,
		choice_context
	)

func is_valid(selected: Array) -> bool:
	if selected.size() < min_count:
		return false
	if selected.size() > max_count:
		return false
	for item in selected:
		if not item is CardInstance:
			return false
		var card :=item as CardInstance
		if card == null:
			return false
		if card not in card_options:
			return false
	return true

#Converting generic response coming from the choicemanager into a typed array:
#Should ONLY be called after is_valid()
func to_card_array(selected: Array) -> Array[CardInstance]:
	var result : Array[CardInstance] = []
	
	if not is_valid(selected):
		push_error("CardChoiceRequest: to_card_array recieved invalid selection")
		return result
		
	for c in selected:
		result.append(c as CardInstance)
		
	return result
