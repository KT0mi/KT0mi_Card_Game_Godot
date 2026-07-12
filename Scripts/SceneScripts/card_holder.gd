extends Area2D
class_name CardHolder

##-1 means unlimited
@export_category("Game Logic Variables")
@export var capacity: int = -1
@export var owner_is_player_one: bool = true
@export var zone_type: Zone.Type = Zone.Type.ARENA

@export_category("Visual Variable")
@export var snap_duration: float = 0.15
@export var show_debug_outline: bool = true
enum Arrangement {STACK, ROW, FAN}
@export var arrangement : Arrangement = Arrangement.STACK
@export var card_spacing: float = 70.0
@export var fan_angle_step_degrees: float = 6.0
@export var fan_arc_height: float = 14.0

var held_cards: Array[Card] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("card_holders")
	input_pickable = false
	CardViewManager.register_holder(self)
	queue_redraw()
	
func _draw() -> void:
	if not show_debug_outline:
		return
 
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or not (shape_node.shape is RectangleShape2D):
		return
 
	var size: Vector2 = shape_node.shape.size
	var rect := Rect2(shape_node.position - size / 2, size)
 
	draw_rect(rect, Color(1, 1, 1, 0.08))
	draw_rect(rect, Color(1, 1, 1, 0.5), false, 2.0)
 
	var label := "%s (P%d) Cards: %d" % [
		Zone.Type.keys()[zone_type],
		1 if owner_is_player_one else 2,
		held_cards.size()
	]
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(4, 16), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13)


func can_accept(_card: Card) -> bool:
	return capacity < 0 or held_cards.size() < capacity
	
func add_card(card: Card) -> void:
	if card in held_cards:
		_arrange_cards()
		return
		
	held_cards.append(card)
	
	if card.get_parent() != self:
		card.reparent(self)
		
	_arrange_cards()
	
func remove_card(card: Card) -> void:
	held_cards.erase(card)
	_arrange_cards()
	
func _arrange_cards() -> void:
	var count := held_cards.size()
	for i in count:
		var card := held_cards[i]
		var target_pos := _target_position(i, count)
		var target_rot := _target_rotation(i, count)
		
		card.set_rest_rotation(target_rot)
		
		var tween := create_tween()
		tween.tween_property(card, "position", target_pos, snap_duration) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			
	queue_redraw()

func _target_position(i : int, count : int) -> Vector2:
	match arrangement:
		Arrangement.STACK:
			return Vector2.ZERO
		Arrangement.ROW:
			return Vector2((i - (count - 1) / 2.0) * card_spacing, 0)
		Arrangement.FAN:
			var offset_from_center := i - (count - 1) / 2.0
			return Vector2(offset_from_center * card_spacing, absf(offset_from_center) * fan_arc_height)
		_:
			return Vector2.ZERO

func _target_rotation(i: int, count: int) -> float:
	if arrangement != Arrangement.FAN:
		return 0.0
	var offset_from_center := i - (count - 1) / 2.0
	return offset_from_center * fan_angle_step_degrees
