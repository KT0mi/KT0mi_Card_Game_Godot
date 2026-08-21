extends Node
##Autoload

##CheckSystem is the 'thought' half of dual system I have: Trigger/Check.
##CheckSystem ONLY answers about the current state, it is a quick calculus about
##any hypothetical value that can be hooked by a ContinuousEffect.
##Everything is synchronous: it does not wait for anything, does not directly mutate anything.

##Gathers any candidates for activating continous effects and folds those effects into
##Categories: 'Kind' -> What it applies to (attacl, endurance, etc.) 
##'Layer' which bucket this effect resolves in; Set effects are absolute, delta are commutative

##If there's any asynchronous event happening it is not a CheckSystem call.

## ----------------------------------------------------
## -------------- CHECKS FUNCTIONS --------------------
## ----------------------------------------------------

func attack_of(card: CardInstance) -> int:
	var value := card.current_attack
	for mod in card.attack_modifiers:
		value = mod.apply(value)
	var key := "attack:%d" % card.get_instance_id()
	return _resolve(
		key, 
		ContinuousEffect.Kind.ATTACK,
		value,
		AttackCheck.new(card)
	)

func endurance_of(card: CardInstance) -> int:
	var value := card.current_endurance
	for mod in card.endurance_modifiers:
		value = mod.apply(value)
	var key := "endurance:%d" % card.get_instance_id()
	return _resolve(
		key,
		ContinuousEffect.Kind.ENDURANCE,
		value,
		EnduranceCheck.new(card)
	)

func gate_of(card: CardInstance) -> CardGate:
	var gate := card.definition.gate
	if gate == null:
		return null
	for mod in card.gate_modifiers:
		gate = mod.apply(gate)
	var key := "gate:%d" % card.get_instance_id()
	return _resolve(
		key,
		ContinuousEffect.Kind.GATE,
		gate,
		GateCheck.new(card)
	)


func playability_of(card: CardInstance, lane: int = -1) -> bool:
	var active_player := _playability_check(
		card,
		PlayabilityCheck.Injectable.ACTIVE_PLAYER,
		lane,
		#This is the base/default check for this injectable of playability
		#If this turns false, the card is not playable
		TurnController.current_player == card.owner,
		"Not active player"
	)
	var in_hand := _playability_check(
		card,
		PlayabilityCheck.Injectable.IN_HAND,
		lane,
		#This is the base/default check for this injectable of playability
		not(card.current_zone != Zone.Type.HAND),
		"Card is not in hand"
	)
	var play_phase := _playability_check(
		card,
		PlayabilityCheck.Injectable.PLAY_PHASE,
		lane,
		#This is the base/default check for this injectable of playability
		not(TurnController.current_phase != TurnController.Phase.PLAY),
		"Not in play phase"
	)
	var not_gated := _playability_check(
		card, 
		PlayabilityCheck.Injectable.GATE,
		lane,
		#This is the base/default check for this injectable of playability
		#If this turns false, the card is not playable
		card.is_not_gated(card.owner.get_player_card().get_endurance()),
		"Card gated"
	)
	var lane_open := _playability_check(
		card,
		PlayabilityCheck.Injectable.LANE_OPEN,
		lane,
		#This is the base/default check for this injectable of playability
		not(card.is_creature() and not card.owner.is_lane_open(lane)),
		"Arena lane not open"
	)
	var card_effects_result := _playability_check(
		card,
		PlayabilityCheck.Injectable.CARD_EFFECT,
		lane,
		#This is the base/default check for this injectable of playability
		true,
		"A current card effect does not allow this card to be played"
	)
	return active_player and in_hand and play_phase and not_gated and lane_open and card_effects_result
	

func _playability_check(card: CardInstance, injectable: PlayabilityCheck.Injectable, lane:int, base_value: bool, label: String) -> bool:
	var key := "playability:%d:%d" % [card.get_instance_id(),injectable]
	var result:bool = _resolve(key, ContinuousEffect.Kind.PLAYABILITY, base_value,PlayabilityCheck.new(card, injectable, lane))
	if not result:
		print("CheckSystem: Card is not playable. Reason: %s" % label)
	return result

## Effect-damage query: "how much damage does `dealing_card`'s effect deal,
## starting from `base_amount`, given every ContinuousEffect currently in
## play that cares about it?" This is the Magma Burst case -- a card with
## card_text like "While this is in play, 'Magma Burst' cards deal +1
## damage" declares a ContinuousEffect.Kind.EFFECT_DAMAGE whose
## applies_to checks `dealing_card.definition.damage_tags.has(&"magma_burst")`
## (tag Magma Burst's own CardDefinition with that tag -- see
## CardDefinition.damage_tags, the same idea as Ability.keywords).
##
## Callers (a SpellCardDefinition's resolve_effect, UI tooltips) call this
## to get the *effective* damage before it's dealt -- it's a pure query,
## so the same call is safe to use for a live "this will deal 4" preview
## and for the actual number passed to DamagePipeline.apply_damage. It
## does not replace DamagePipeline's own DAMAGE_REQUEST -- that's still
## the right place for reactive interception (redirect, prevent, trigger
## off damage). This is upstream of that: it decides the number
## DamagePipeline gets handed in the first place.

func effect_damage_of(dealing_card: CardInstance, base_amount: int) -> int:
	var key := "effect_damage:%d" % dealing_card.get_instance_id()
	return _resolve(
		key,
		ContinuousEffect.Kind.EFFECT_DAMAGE,
		base_amount,
		EffectDamageCheck.new(dealing_card)
	)

## ----------------------------------------------------
## --------------- INTERNAL FUNCTIONS -----------------
## ----------------------------------------------------

## Tracks queries currently in progress, keyed by the string built in each
## public function above. If a card's effect Callable turns around and
## queries CheckSystem again for the same thing it's already in the
## middle of resolving (e.g. two cards each defining their Attack as
## "equal to the other's"), that's a genuine dependency cycle -- there is
## no correct answer, only an arbitrary one. Rather than stack-overflow or
## silently pick a winner, this detects the re-entry, warns loudly (so you
## find out at test time, not from a confused bug report later), and
## falls back to the pre-continuous-effects base value for that call.
var _resolving : Dictionary = {}

func _resolve(key: String, kind : ContinuousEffect.Kind, start:Variant, context: CheckContext) -> Variant:
	if _resolving.has(key):
		push_warning("CheckSystem: Dependency Cycle detected. Falling back to base value")
		return start
	_resolving[key] = true
	var matches := _collect(kind, context)
	var value : Variant = _apply_layers(start, context, matches)
	_resolving.erase(key)
	return value

##Gathers an array of {"source": CardInstance, "ce": ContinuousEffect} pairs of given
##'kind' whose 'predicate' matches, fomr every currently-active source on the board.
##Sorted by CardInstance.continuous_sinse so layers can sort by timestamp.
##Predicate is generically:
#	func(source : CardInstance, ce: ContinuousEffect) -> bool:
#		return ce.applies_to.call(source, card))
func _collect(kind: ContinuousEffect.Kind, context: CheckContext) -> Array:
	var matches : Array = []
	for source in GameState.all_player_cards(): ##TODO maybe too hard on the processor
		if not GameState.is_continuous_source_active(source):
			continue
		for ce in source.definition.get_continuous_effects():
			if ce.kind != kind:
				continue
			if ce.applies_to.call(source, context):
				matches.append({"source": source, "ce": ce})
	matches.sort_custom(func(a, b): return a.source.continuous_since < b.source.continuous_since)
	return matches

##Layer Rules: SET layers resolve first (last established source wins)
##Then DELTA layers fold on top of absolute value.
func _apply_layers(start : Variant, context: CheckContext, matches: Array) -> Variant:
	var value : Variant = start
	for m in matches:
		if m.ce.layer == ContinuousEffect.Layer.SET:
			value = m.ce.effect.call(value, m.source, context)
	for m in matches:
		if m.ce.layer == ContinuousEffect.Layer.DELTA:
			value = m.ce.effect.call(value, m.source, context)
	for m in matches:
		if m.ce.layer == ContinuousEffect.Layer.FINAL:
			value = m.ce.effect.call(value, m.source, context)
	return value
