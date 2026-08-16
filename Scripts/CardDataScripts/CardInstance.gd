class_name CardInstance extends RefCounted

var definition: CardDefinition
var owner: Player

var current_zone: Zone.Type = Zone.Type.DECK
var lane: int = -1
var current_endurance: int = 0
var current_attack : int = 0

## Stamped by ZoneManager.move_to whenever this card enters a zone where
## GameState.is_continuous_source_active would be true. Used only to order
## SET-layer ContinuousEffects deterministically ("most recently
## established wins") -- see CheckSystem._resolve. -1 means "never
## activated," which naturally sorts before anything real.
var continuous_since: int = -1


signal counter_changed(card : CardInstance, key : StringName)
signal flag_changed(card : CardInstance, flag : StringName)

var counters: Dictionary = {}
var flags: Dictionary = {}

#Typed modifier arrays for type safety when parsing modifiers
#These are permanent (Default: Added, auto-cleanup) modifiers.
#These are not conditional: They are pushed into the card
var attack_modifiers : Array[StatModifer] = []
var endurance_modifiers : Array[StatModifer] = []
var gate_modifiers : Array[GateModifier] = []

func _init(def: CardDefinition, p: Player) -> void:
	definition = def
	owner = p
	if def is CreatureCardDefinition:
		current_endurance = def.endurance
		current_attack = def.attack

func get_id() -> StringName:
	return definition.id

func is_creature() -> bool:
	return definition is CreatureCardDefinition
	
func is_spell() -> bool:
	return definition is SpellCardDefinition
	
func is_playable(against : int) -> bool:
	var gate := get_gate()
	if gate == null:
		return true
	return gate.is_playable(against)

func is_battle_ready() -> bool:
	#If the card is dazed
	if get_flag(CardKeywords.DAZED): return false
	
	if definition is CreatureCardDefinition:
		return definition.is_battle_ready(self)
	return true


func reset_stats() -> void:
	if definition is CreatureCardDefinition:
		current_endurance = definition.endurance
		current_attack = definition.attack

## Attribute Parsers - methods for parsing the current stats of the card given any modifiers

func get_display_text() -> String:
	return definition.get_display_text(self)

func get_attack() -> int:
	var value := current_attack
	for modifier in attack_modifiers:
		value = modifier.apply(value)
	return value

func get_endurance() -> int:
	var value := current_endurance
	for modifer in endurance_modifiers:	
		value = modifer.apply(value)
	return value
	
func get_gate() -> CardGate:
	var gate := definition.gate
	if gate == null:
		return null
	for modifier in gate_modifiers:
		gate = modifier.apply(gate)
	return gate

## --- Counters --------------------------------
func get_counter(key: StringName) -> int:
	return counters.get(key, 0)

func has_counter(key: StringName) -> int:
	return get_counter(key) != 0
	
#Setting to 0 erases counter
func set_counter(key: StringName, value: int) -> void:
	if value ==	 0:
		counters.erase(key)
	else:
		counters[key] = value
	counter_changed.emit(self, key)

## Convenience for "N turns/triggers remaining" countdowns: decrements
## and clamps at 0, so a stray extra tick can't go negative and quietly
## change the meaning of a `get_counter(key) <= 0` check.
func tick_counter(key: StringName, amount: int = 1) -> int:
	var value := maxi(get_counter(key) - amount, 0)
	set_counter(key, value)
	return value

# --- Flags ------------------------------------------
func get_flag(key: StringName) -> bool:
	return flags.get(key, false)

func has_flag(key: StringName) -> bool:
	return flags.has(key)
	
func set_flag(key: StringName, value: bool) -> void:
	flags[key] = value
	flag_changed.emit(self, key)

## --- Cleanup ----------------------------------------------------------------
 
## Removes a specific durable modifier, e.g. when its duration ends.
func remove_modifier(array: Array, modifier: Modifier) -> void:
	array.erase(modifier)
 
func clear_all_modifiers() -> void:
	attack_modifiers.clear()
	endurance_modifiers.clear()
	gate_modifiers.clear()

## Strips every modifier granted by `src`, across all three arrays. Hook
## this into whatever event handler notices a card leaving play, to clean
## up any "while this card is in play" buffs it granted elsewhere.
func clear_modifiers_from(src: CardInstance) -> void:
	_strip_source(attack_modifiers, src)
	_strip_source(endurance_modifiers, src)
	_strip_source(gate_modifiers, src)
 
func _strip_source(array: Array, src: CardInstance) -> void:
	for i in range(array.size() - 1, -1, -1):
		if array[i].source == src:
			array.remove_at(i)
