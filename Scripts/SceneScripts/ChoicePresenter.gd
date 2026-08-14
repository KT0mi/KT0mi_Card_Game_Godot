class_name CardChoicePresenter extends Control


@onready var prompt_label: Label = $ChoiceLabelContainer/PromptLabel
@onready var selection_label: Label = $ChoiceLabelContainer/SelectionLabel
@onready var confirm_button: Button = $ChoiceLabelContainer/ConfirmButton

var _request: ChoiceRequest = null
var _selected: Array = []

func _ready() -> void:
	visible = false
	confirm_button.pressed.connect(_on_confirm_pressed)
	ChoiceManager.choice_requested.connect(begin)

func _refresh() -> void:
	if _request == null:
		return
	
	selection_label.text = "%d/%d selected" % [_selected.size(), _request.max_count]
	
	confirm_button.disabled =  not _request.is_valid(_selected)

#region Generic Methods

func begin(request: ChoiceRequest) -> void:
	assert(_request == null, "ChoicePresenter already has an active request.")
	
	_request = request
	_selected.clear()
	
	prompt_label.text = request.prompt
	
	#Branch into specific ChoiceRequest
	if request is CardChoiceRequest:
		setup_card_choice(request)
	
	_refresh()
	visible = true

func _finish(request : ChoiceRequest) -> void:
	#Identity guard
	#This means that I never allow a cleanup of an old request to influence a new request
	if _request != request:
		return
	
	if request != null:
		if request is CardChoiceRequest:
			_clear_card_selection()
	
	_selected.clear()
	_request = null
	
	prompt_label.text = ""
	selection_label.text = ""
	confirm_button.disabled = true
	
	visible = false

func _on_confirm_pressed() -> void:
	if _request == null:
		return
		
	if not _request.is_valid(_selected):
		return
	
	var finishing_request := _request
	
	var response: Array = []
	response.append_array(_selected)
	
	_finish(finishing_request)
	
	var submitted := await ChoiceManager.submit(response)
	
	if not submitted:
		push_error(
			"CardChoicePresenter: valid active request was rejected."
		)

#endregion

#region CardChoiceRequest presenting methods

func setup_card_choice(request: CardChoiceRequest) -> void:
	_set_cards_for_choice(request)

func _card_request_cleanup(request : CardChoiceRequest) -> void:
	for card in request.card_options:
		var node := CardViewManager.card_node_for(card)
		
		if node == null:
			push_warning("ChoicePresenter: No card node for %s" % card.get_id())
			continue
			
		if node.selection_pressed.is_connected(_on_card_selection_pressed):
			node.selection_pressed.disconnect(_on_card_selection_pressed)
			
	for node in CardViewManager.get_all_card_nodes():
		if node:
			node.set_interaction_mode(Card.InteractionMode.NORMAL)

func _set_cards_for_choice(request: CardChoiceRequest) -> void:
	#Block Normal card interaction by disabling card
	for node : Card in CardViewManager.get_all_card_nodes():
		if node == null: continue
		
		node.set_interaction_mode(Card.InteractionMode.DISABLED)
	
	for card in request.card_options:
		var node := CardViewManager.card_node_for(card)
		
		if node == null:
			push_warning("ChoicePresenter: no Card node found for %s" % card.definition.id)
			continue
		
		node.set_interaction_mode(Card.InteractionMode.SELECTABLE)
		
		node.selection_pressed.connect(_on_card_selection_pressed)

func _on_card_selection_pressed(node: Card) -> void:
	if _request == null:
		push_warning("ChoicePresenter: Trying to select card node for null ChoiceRequest")
		return
		
	var card := node.card_instance
	
	if card not in _request.card_options:
		push_warning("ChoicePresenter: Trying to select card that is not in ChoiceRequest options")
		return
		
	if card in _selected:
		_selected.erase(card)
		node.set_selected(false)
	elif _request.max_count == 1:
		_clear_card_selection()
		
		_selected.append(card)
		node.set_selected(true)
		
	elif _selected.size() < _request.max_count:
		_selected.append(card)
		node.set_selected(true)
		
	_refresh()

func _clear_card_selection() -> void:
	for card : CardInstance in _selected:
		var node := CardViewManager.card_node_for(card)
		
		if node:
			node.set_selected(false)
	
	_selected.clear()
	
#endregion
