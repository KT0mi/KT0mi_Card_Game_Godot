extends Node
##Autoload

# Main script to sync visuals and card game logic

var _card_nodes: Dictionary = {} #CardInstance -> Card (Scene)
var _holder_nodes: Dictionary = {} #"player id: zone type" : CardHolder (Scene)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ZoneManager.card_zone_changed.connect(_on_zone_changed)
	GameActions.card_stat_changed.connect(_refresh_card_visuals)
	DamagePipeline.change_card_endurance.connect(_refresh_card_visuals)
	
#Called by CardHolder._ready()
func register_holder(holder: CardHolder) -> void:
	var player := GameState.player_one if holder.owner_is_player_one else GameState.player_two
	_holder_nodes[_key(player, holder.zone_type, holder.lane_index)] = holder

#Called by Card._ready()
func register_card_node(instance: CardInstance, node: Card) -> void:
	_card_nodes[instance] = node
	node._setup_visuals()
	#Connection point for each card to update their visuals when their counters or flags are changed
	instance.counter_changed.connect(func(_card, _counter): node._refresh_visuals())
	instance.flag_changed.connect(func(_card, _flag): node._refresh_visuals())

func _on_zone_changed(card: CardInstance, from_zone: Zone.Type, to_zone: Zone.Type, from_lane: int = -1, to_lane: int = -1) -> void:
	var node: Card = _card_nodes.get(card)
	if node == null:
		return  # card has no visual representation yet/anymore -- fine, e.g. still in deck
	
	var old_holder : CardHolder = _holder_nodes.get(_key(card.owner, from_zone, from_lane))
	if old_holder:
		old_holder.remove_card(node)
	
	var holder: CardHolder = _holder_nodes.get(_key(card.owner, to_zone, to_lane))
	if holder:
		holder.add_card(node)
		
	node._refresh_visuals()

func _key(player: Player, zone: Zone.Type, lane : int = -1) -> String:
	return "%s:%s:%s" % [player.get_instance_id(), zone, lane]
	
func holder_for(card_instance: CardInstance) -> CardHolder:
	if card_instance == null:
		return null
	return _holder_nodes.get(_key(card_instance.owner, card_instance.current_zone, card_instance.lane))
	
func card_node_for(instance: CardInstance) -> Card:
	return _card_nodes.get(instance)

func holder_at_point(global_point: Vector2) -> CardHolder:
	for holder in _holder_nodes.values():
		if holder.contains_point(global_point):
			return holder
	return null

func is_card_hidden_from_local_view(card_instance) -> bool:
	if card_instance == null:
		return false
	if card_instance.current_zone == Zone.Type.DECK:
		return true
	if card_instance.current_zone == Zone.Type.HAND and card_instance.owner != GameState.local_player:
		return true
	return false

func _refresh_card_visuals(card_instance: CardInstance) -> void:
	var card := card_node_for(card_instance)
	card._refresh_visuals()

func refresh_gate_label(card_instance: CardInstance) -> String:
	var gate := card_instance.get_gate()
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
