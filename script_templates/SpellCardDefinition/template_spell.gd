extends _BASE_

func _init() -> void:
	id = &"_CLASS_SNAKE_CASE_"
	card_name = ""
	card_text = ""
	gate = CardGate.None()
	cast_type = CastType
	

func resolve_effect(_card: CardInstance, _event: PlayCardEvent) -> void:
	pass
	
