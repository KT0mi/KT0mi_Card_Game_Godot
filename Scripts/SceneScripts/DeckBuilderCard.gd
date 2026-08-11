extends PanelContainer

signal add_requested(id: StringName)
signal remove_requested(id: StringName)
var add_disabled : bool = false
var remove_disabled : bool = true

#Visual Vars
@onready var sprite: Sprite2D = $Sprite
@onready var name_label: Label = $Labels/Name/NameLabel
@onready var attack_label: Label = $Labels/Attack/AttackLabel
@onready var endurance_label: Label = $Labels/Endurance/EnduranceLabel
@onready var gate_label: Label = $Labels/Gate/GateLabel
@onready var card_text_label: RichTextLabel = $Labels/CardText/CardTextLabel

var definition : CardDefinition

func _ready() -> void:
	gui_input.connect(_on_input_event)

func setup(def: CardDefinition) -> void:
	definition = def
	sprite.texture = def.art
	name_label.text = def.card_name
	card_text_label.text = def.card_text
	gate_label.text = _setup_gate_label(def)
	
	if def is CreatureCardDefinition:
		attack_label.text = str(def.attack)
		endurance_label.text = str(def.endurance)
	else:
		attack_label.visible = false
		endurance_label.visible = false
	

func _setup_gate_label(def : CardDefinition) -> String:
	var gate : CardGate = def.gate
	if gate == null:
		return ""
	match gate.gate_type:
		CardGate.GateType.NONE:
			return ""
		CardGate.GateType.LESS_THAN:
			return "<%d" % gate.value
		CardGate.GateType.GREATER_THAN:
			return ">%d" % gate.value
		CardGate.GateType.INTERVAL:
			return "%d-%d" % [gate.lower_bound, gate.upper_bound]
		_:
			return ""

func refresh_count(count: int, max_copies: int) -> void:
	add_disabled = count >= max_copies
	remove_disabled = count <= 0

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT and not add_disabled:
			add_requested.emit(definition.id)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT and not remove_disabled:
			remove_requested.emit(definition.id)
			get_viewport().set_input_as_handled()
	
