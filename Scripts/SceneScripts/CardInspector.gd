extends CanvasLayer
##Autoload

@onready var _overlay: Control = $Overlay
@onready var _dim_background: ColorRect = $Overlay/DimBackground

@onready var _name_label : Label = $Overlay/CardElementContainer/CardName
@onready var _text_box : RichTextLabel = $Overlay/CardElementContainer/CardText
@onready var _endurance_label : Label = $Overlay/CardElementContainer/StatContainer/EnduranceLabel
@onready var _gate_label : Label = $Overlay/CardElementContainer/StatContainer/GateLabel
@onready var _attack_label : Label = $Overlay/CardElementContainer/StatContainer/AttackLabel

@onready var _modifiers_list : VBoxContainer = $Overlay/CardModifierContainer

var DEFAULT_THEME : Theme = preload("res://Theme/default_theme.tres")
const MODIFIER_ENTRY_SCENE := preload("res://Scenes/UI/ModifierEntry.tscn")

var _card : CardInstance = null

func _ready() -> void:
	layer = 90
	_overlay.visible = false
	_dim_background.gui_input.connect(_on_dim_background_input)
	
func open(card: CardInstance) -> void:
	if card == null: return
	_card = card
	_refresh()
	_overlay.visible = true

func close() -> void:
	if not _overlay.visible: return
	_card = null
	_overlay.visible = false

func is_open() -> bool:
	return _overlay.visible
	
func _unhandled_input(event: InputEvent) -> void:
	if not _overlay.visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()

func _on_dim_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close()

## --- Populating

func _refresh() -> void:
	var def: CardDefinition = _card.definition
	
	_name_label.text = def.card_name
	_text_box.text = _card.get_display_text()
	
	if def is CreatureCardDefinition:
		_attack_label.visible = true
		_endurance_label.visible = true
		_attack_label.text = "Attack:\n%d" % _card.get_attack()
		_endurance_label.text = "Endurance:\n%d" % _card.get_endurance()
	else:
		_attack_label.visible = false
		_endurance_label.visible = false
	
	_gate_label.text = "Gate:\n%s" % CardViewManager.format_gate_label(_card.get_gate())
	
	_rebuild_modifiers_list()

func _rebuild_modifiers_list() -> void:
	for child in _modifiers_list.get_children():
		child.queue_free()
	
	var sections : Array = []
	if _card.definition is CreatureCardDefinition:
		sections.append(["Attack", ContinuousEffect.Kind.ATTACK, _card.current_attack, _card.attack_modifiers])
		sections.append(["Endurance",ContinuousEffect.Kind.ENDURANCE, _card.current_endurance, _card.endurance_modifiers])
	sections.append(["Gate",ContinuousEffect.Kind.ENDURANCE, _card.definition.gate, _card.gate_modifiers])
	
	var any_entries := false
	for section in sections:
		var entries := _build_timeline(section[1], section[2], section[3])
		if entries.is_empty():
			continue
		any_entries = true
		_add_header(section[0])
		for entry in entries:
			_add_modifier_entry(
				section[2],
				section[0],
				entry[0],
				entry[1],
				entry[2])
	
	if not any_entries:
		_add_header("No active modifiers or continuous effects.")

func _build_timeline(kind : ContinuousEffect.Kind, start_value, permanent_modifiers:Array) -> Array[Array]:
	var entries : Array[Array] = []
	var value = start_value
	
	for mod in permanent_modifiers:
		var before = value
		value = mod.apply(value)
		var label : String = mod.label if mod.label != "" else "Modifier"
		var src_name : String = mod.source.definition.card_name if mod.source else "Unknown"
		entries.append([
			src_name,
			label,
			_format_value(value, before)
		])
		
	for m in _collect_continuous(kind, ContinuousEffect.Layer.SET):
		var before = value
		value = m.ce.effect.call(value, m.source)
		entries.append([
			m.source.definition.card_name,
			m.ce.label,
			_format_value(value, before)
		])
	
	for m in _collect_continuous(kind, ContinuousEffect.Layer.DELTA):
		var before = value
		value = m.ce.effect.call(value, m.source)
		entries.append([
			m.source.definition.card_name,
			m.ce.label,
			_format_value(value, before)
		])
	
	return entries

func _format_value(value, before) -> String:
	if value is CardGate:
		return CardViewManager.format_gate_label(value)
	return str(value)
	

## Gathers every currently-active ContinuousEffect of the given kind/layer
## whose applies_to(source, this_card) matches, sorted oldest-source-first
## -- mirrors CheckSystem._collect, but scoped to a single card as target
## since that's all the popup needs.
func _collect_continuous(kind: ContinuousEffect.Kind, layer: ContinuousEffect.Layer) -> Array:
	var matches : Array = []
	for source : CardInstance in GameState.all_player_cards():
		if not GameState.is_continuous_source_active(source):
			continue
		for ce in source.definition.get_continuous_effects():
			if ce.kind != kind or ce.layer != layer:
				continue
			if ce.applies_to.call(source, _card):
				matches.append({"source": source, "ce": ce})
	matches.sort_custom(func(a, b): return a.source.continuous_since < b.source.continuous_since)
	return matches

func _add_header(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.theme = DEFAULT_THEME
	label.add_theme_font_size_override("font_size", 22)
	_modifiers_list.add_child(label)

func _add_modifier_entry(against, kind_text: String, source_text: String, modifier_text: String, new_value: String) -> void:
	var entry : ModifierEntry = MODIFIER_ENTRY_SCENE.instantiate()
	entry.kind_text = kind_text
	entry.source_text = source_text
	if modifier_text == "": entry.modifier_label.visible = false
	else: entry.modifier_text = modifier_text
	if not against is CardGate:
		if against > int(new_value):
			entry.new_value_label.add_theme_color_override("font_color", Color.RED)
		elif against < int(new_value):
			entry.new_value_label.add_theme_color_override("font_color", Color.GREEN)
	entry.new_value_text = new_value
	_modifiers_list.add_child(entry)
