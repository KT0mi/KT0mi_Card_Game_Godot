extends Area2D
class_name CardHolder

@export var capacity: int = 1

@export var snap_duration: float = 0.15

var held_cards: Array[Card] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("card_holders")
	input_pickable = false

func can_accept(_card: Card) -> bool:
	return capacity < 0 or held_cards.size() < capacity
	
func add_card(card: Card) -> void:
	if card in held_cards:
		return
		
	held_cards.append(card)
	
	if card.get_parent() != self:
		card.reparent(self)
		
	_arrange_cards()
	
func remove_card(card: Card) -> void:
	held_cards.erase(card)
	_arrange_cards()
	
func _arrange_cards() -> void:
	for i in held_cards.size():
		var card := held_cards[i]
		var target_local_pos := Vector2.ZERO
		
		var tween := create_tween()
		tween.tween_property(card, "position", target_local_pos, snap_duration) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
