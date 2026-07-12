extends Area2D
class_name Card

signal picked_up(card: Card)
signal dropped(card: Card)

#Movement vars
@export var spring_stiffness: float = 0.2
@export var damping: float = 0.1
@export var tilt_strength: float = 1.0
@export var max_tilt_degrees: float = 10.0
@export var tilt_recover_speed: float = 10.0

var dragging: bool = false
var velocity: Vector2 = Vector2.ZERO
var rest_rotation_degrees: float = 0.0
func set_rest_rotation(degrees: float) -> void:
	rest_rotation_degrees = degrees

static var _active_drag: Card = null
const HOVER_Z_INDEX := 100

#Visual Vars
@onready var name_label: Label = $NameLabel
@onready var attack_label: Label = $AttackLabel
@onready var endurance_label: Label = $EnduranceLabel
@onready var card_text_label: Label = $CardTextLabel
@onready var card_back: ColorRect = $CardBack
@onready var hidden_overlay: ColorRect = $HiddenOverlay

var hovered: bool = false
var selected: bool = false
var _drop_target: CardHolder = null

var card_instance: CardInstance = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("cards")
	input_pickable = true
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	get_viewport().physics_object_picking_first_only = true
	DebugSettings.reveal_hidden_cards_changed.connect(func(_v): _update_hidden_state())
	
func bind(instance: CardInstance) -> void:
	card_instance = instance
	CardViewManager.register_card_node(instance, self)
	_refresh_visuals()
	
func _refresh_visuals() -> void:
	#Fill with visual representation of card instance
	var def : CardDefinition = card_instance.definition
	name_label.text = def.card_name
	card_text_label.text = def.card_text
	if def is CreatureCardDefinition:
		endurance_label.text = "%d" % card_instance.current_endurance
		attack_label.text = "%d" % def.attack
	else:
		endurance_label.text = ""
		attack_label.text = ""
	_update_hidden_state()

func _update_hidden_state() -> void:
	var hidden := CardViewManager.is_card_hidden_from_local_view(card_instance)
	var reveal := DebugSettings.reveal_hidden_cards
	
	card_back.visible = hidden and not reveal
	hidden_overlay.visible = hidden and reveal

func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()
 
func _on_mouse_entered() -> void:
	hovered = true
	queue_redraw()
 
func _on_mouse_exited() -> void:
	hovered = false
	queue_redraw()
 
func _draw() -> void:
	#Selection wins over hover when both are true, so you can tell a
	#chosen card apart from one you're merely mousing over while choosing.
	if selected:
		_draw_outline(Color(0.3, 0.6, 1.0, 0.95), 5.0)
	elif hovered:
		_draw_outline(Color(1, 1, 1, 0.6), 5)
 
func _draw_outline(color: Color, width: float) -> void:
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or not (shape_node.shape is RectangleShape2D):
		return
	var size: Vector2 = shape_node.shape.size
	var rect := Rect2(shape_node.position - size / 2, size)
	draw_rect(rect, color, false, width)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and not dragging:
			_start_drag()

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			_end_drag()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if dragging:
		var target := get_global_mouse_position()
		velocity = velocity * damping + (target - global_position) * spring_stiffness
		global_position += velocity
		
		rotation_degrees = clamp(velocity.x * tilt_strength, -max_tilt_degrees, max_tilt_degrees)
		_update_drop_target(target)
	else:
		rotation_degrees = move_toward(rotation_degrees, rest_rotation_degrees, tilt_recover_speed)
		
	
func _start_drag() -> void:
	if _active_drag != null:
		return
		
	_active_drag = self
	dragging = true
	velocity = Vector2.ZERO
	z_index = HOVER_Z_INDEX
	
	picked_up.emit(self)
	
func _update_drop_target(mouse_pos: Vector2) -> void:
	var candidate := CardViewManager.holder_at_point(mouse_pos)
	if candidate == _drop_target:
		return
	if _drop_target:
		_drop_target.set_hovered(false)
	_drop_target = candidate
	if _drop_target:
		_drop_target.set_hovered(true)

func _end_drag() -> void:
	dragging = false
	z_index = 0
	
	if _active_drag == self:
		_active_drag = null
	
	dropped.emit(self)
	
	var holder := _drop_target
	if holder:
		holder.set_hovered(false)
	_drop_target = null
	
	var moved := false
	if holder and card_instance:
		moved = await _attempt_card_action(holder)
	
	if not moved:
		_snap_back_to_current_holder()

func _attempt_card_action(holder: CardHolder) -> bool:
	if holder.zone_type == Zone.Type.ARENA:
		return await GameActions.try_play_card(card_instance.owner, card_instance)
	return false

func _snap_back_to_current_holder() -> void:
	#Illegal move or dropped from empty space
	var holder: CardHolder = CardViewManager.holder_for(card_instance)
	if holder:
		holder.add_card(self)
