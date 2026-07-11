extends Area2D
class_name Card

signal picked_up(card: Card)
signal dropped(card: Card)
signal snapped(card: Card, holder, CardHolder)

@export var spring_stiffness: float = 0.2
@export var damping: float = 0.1

@export var tilt_strength: float = 1.0
@export var max_tilt_degrees: float = 10.0
@export var tilt_recover_speed: float = 10.0

var dragging: bool = false
var velocity: Vector2 = Vector2.ZERO
var current_holder: CardHolder = null

static var _active_drag: Card = null

const HOVER_Z_INDEX := 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("cards")
	input_pickable = true
	input_event.connect(_on_input_event)
	
	get_viewport().physics_object_picking_first_only = true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and not dragging:
			_start_drag()

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			_end_drag()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if dragging:
		var target := get_global_mouse_position()
		velocity = velocity * damping + (target - global_position) * spring_stiffness
		global_position += velocity
		
		rotation_degrees = clamp(velocity.x * tilt_strength, -max_tilt_degrees, max_tilt_degrees)
	else:
		rotation_degrees = move_toward(rotation_degrees, 0.0, tilt_recover_speed)
		
	
func _start_drag() -> void:
	if _active_drag != null:
		return
		
	_active_drag = self
	dragging = true
	velocity = Vector2.ZERO
	z_index = HOVER_Z_INDEX
	
	if current_holder:
		current_holder.remove_card(self)
		current_holder = null
		
	picked_up.emit(self)

func _end_drag() -> void:
	dragging = false
	z_index = 0
	
	if _active_drag == self:
		_active_drag = null
	
	dropped.emit(self)
	
	var holder := _find_best_holder()
	if holder:
		snap_to_holder(holder)
	else: 
		if current_holder:
			snap_to_holder(current_holder)

func _find_best_holder() -> CardHolder:
	var best: CardHolder = null
	var best_dist := INF
	
	for area in get_overlapping_areas():
		if area is CardHolder and area.can_accept(self):
			var d := global_position.distance_squared_to(area.global_position)
			if d < best_dist:
				best_dist = d
				best = area
	return best

func snap_to_holder(holder: CardHolder) -> void:
	current_holder = holder
	holder.add_card(self)
	snapped.emit(self, holder)
