extends Node
##Autoload

#Bare-minimum opponent for playtesting -- not meant to be smart, just
#competent enough that you don't have to control both seats yourself.
#Hooks the exact same public entry points a human uses (GameActions,
#ChoiceManager) rather than anything privileged, so it can never do
#something a human player couldn't do through the normal UI.

@export var ai_player_is_player_two: bool = true
@export var action_delay: float = 0.6
@export var phase_delay: float = 1.0

func _ready() -> void:
	TurnController.phase_changed.connect(_on_phase_changed)
	ChoiceManager.choice_requested.connect(_on_choice_requested)

func _ai_player() -> Player:
	return GameState.player_two if ai_player_is_player_two else GameState.player_one

func _think() -> void:
	await get_tree().create_timer(action_delay).timeout

func _on_phase_changed(phase: TurnController.Phase, player: Player, forgetting) -> void:
	if player != _ai_player():
		return
	if forgetting:
		return
	if phase == TurnController.Phase.START_TURN:
		await _take_start_turn_phase_actions()
	if phase == TurnController.Phase.PLAY:
		await _take_play_phase_actions()
	
	#Check if current player again
	if TurnController.current_player != _ai_player():
		print("AIController: Current Player is no longer AI")
		return
	await get_tree().create_timer(phase_delay).timeout
	await TurnController.advance_phase()

func _take_start_turn_phase_actions() -> void:
	#Heuristics for choosing to "Forget Turn" or not
	
	#If you can play any cards in your hand
	for card : CardInstance in _ai_player().hand:
		if card.is_not_gated(_ai_player().get_player_card().get_endurance()):
			return
	
	#If you have 3 or fewer cards in hand
	if _ai_player().hand.size() < 4:
		return
	
	#If any cards in your arena can attack
	for card : CardInstance in _ai_player().arena():
		if not card.has_counter(CardKeywords.DAZED):
			if card.is_creature():
				var def : CreatureCardDefinition = card.definition
				if def.is_battle_ready(card): 
					return
	
	#Then forget
	await TurnController.forget_turn()

func _take_play_phase_actions() -> void:
	var ai := _ai_player()
	#Play Heuristic: Play creatures first, then spells
	#Play Strongest Creatures first in the first possible lane
	
	#Collect all playable creatures and spells into respective containers
	var p_creatures : Array[CardInstance]
	var p_spells : Array[CardInstance]
	
	for card:CardInstance in ai.hand.duplicate():
		if card.is_not_gated(_ai_player().get_player_card().get_endurance()):
			if card.is_creature(): p_creatures.append(card)
			else: p_spells.append(card)
	
	print("AIController: Ai can play cards: %s and %s" % [str(p_creatures),str(p_spells)])
	
	#Sort playable creatures by their pure stat total (attack+endurance)
	p_creatures.sort_custom(func(a:CardInstance,b:CardInstance):
		var a_total := a.get_attack() + a.get_attack()
		var b_total := b.get_attack() + b.get_endurance()
		return a_total > b_total)
	
	#Play sorted creature cards
	for card:CardInstance in p_creatures:
		print("AIController: Trying to play card: %s" % card.get_id())
		for i in range(ai.ARENA_LANES):
			var successful := await GameActions.try_play_card(ai, card, i) 
			i+=1
			if successful:
				break
		await _think()
	
	#Play spells
	for card:CardInstance in p_spells:
		await GameActions.try_play_card(ai, card)
		await _think()


func _on_choice_requested(request: ChoiceRequest) -> void:
	if request.requesting_player != _ai_player():
		return  #not the AI's decision -- leave it for the human-facing UI
	
	await _think()
	
	var selected: Array = _choose(request)
	ChoiceManager.submit(selected)

func _choose(request: ChoiceRequest) -> Array:
	if request is CardChoiceRequest:
		return _choose_cards(request as CardChoiceRequest)
	else:
		return _brute_choice(request)

func _choose_cards(request : CardChoiceRequest) -> Array:
	match request.context.origin:
		ChoiceContext.Origin.STATE_ACTION:
			match request.context.intent:
				ChoiceContext.Intent.BATTLE:
					#take as many options as allowed
					var selected: Array = request.options.slice(0, request.max_count)
					return selected
				ChoiceContext.Intent.MULLIGAN:
					#Mulligan any card that you cannot play on the first turn
					var selected : Array
					for c : CardInstance in request.options:
						if c.is_not_gated(_ai_player().get_player_card().get_endurance()):
							continue
						selected.append(c)
					return selected
				_:
					return _brute_choice(request)
		ChoiceContext.Origin.CARD_EFFECT:
			match request.context.intent:
				ChoiceContext.Intent.DAMAGE:
					#Damage effect Heuristic:
					#	X If the damage is lethal to the opponent, deal it to the opponent.
					#	X If the damage is lethal to the opponent's arena creatures, 
					#deal it to the strongest creature it is lethal to.
					#	X If the damage is neither lethal to the opponent nor to any of 
					#their arena cards, deal it to the opponent.
					#	X If the opponent_card is not an option, deal it to the strongest opponent creature.
					#	X If the damage cannot be dealt to an opponent card,
					#deal it to the weakest creature on your arena it is not lethal to.
					#	X If there is no card in your arena the damage is not lethal to, 
					#deal it to the weakest card in your arena.
					#	X If there is no creature card on your arena, deal it to yourself.
					var selected : Array[CardInstance] = []
					
					var opponent_card : CardInstance = null
					var opponent_creatures : Array[CardInstance] = []
					var player_card : CardInstance = null
					var player_creatures : Array[CardInstance] = []
					
					#Candidate gathering
					for card : CardInstance in request.card_options:
						if card.owner != _ai_player():
							if card.is_player_card(): 
								opponent_card = card
								continue
							if card.is_creature():
								opponent_creatures.append(card)
								continue
						else:
							if card.is_player_card():
								player_card = card
								continue
							if card.is_creature():
								player_creatures.append(card)
								continue
					
					#If the opponent card is a valid target and the damage is lethal
					#Choose it
					if opponent_card != null:
						if opponent_card.get_endurance() <= request.context.amount:
							selected.append(opponent_card)
							if _is_selection_full(selected, request): return selected
					
					if not opponent_creatures.is_empty():
						#Sort by strongest
						opponent_creatures.sort_custom(func(a:CardInstance,b:CardInstance):
							return (a.get_attack()+a.get_endurance()) > (b.get_attack()+b.get_endurance())
						)
						for c in opponent_creatures:
							if c.get_endurance() <= request.context.amount:
								selected.append(c)
								if _is_selection_full(selected,request): return selected
						if opponent_card != null and not selected.has(opponent_card):
							selected.append(opponent_card)
							if _is_selection_full(selected, request): return selected
						for c in opponent_creatures:
							if not selected.has(c): selected.append(c)
							if _is_selection_full(selected, request): return selected
					
					if opponent_card != null:
						selected.append(opponent_card)
						if _is_selection_full(selected, request): return selected
					
					if not player_creatures.is_empty():
						#Sort by weakest
						player_creatures.sort_custom(func(a:CardInstance,b:CardInstance):
							return (a.get_attack()+a.get_endurance()) < (b.get_attack()+b.get_endurance())
						)
						for c in player_creatures:
							if c.get_endurance() > request.context.amount:
								selected.append(c)
								if _is_selection_full(selected,request): return selected
						for c in player_creatures:
							if not selected.has(c): selected.append(c)
							if _is_selection_full(selected, request): return selected
					
					if player_card != null:
						selected.append(player_card)
						if _is_selection_full(selected, request): return selected
					
					if selected.size() < request.min_count:
						return _brute_choice(request)
					
					return selected
				ChoiceContext.Intent.KILL:
					##Kill effect heuristics:
					#	Kill strongest opponent creatures first
					#	Kill weakest owned creatures
					#	Randomize if failed
					var selected : Array[CardInstance] = []
					
					var opponent_creatures : Array[CardInstance] = []
					var owned_creatures : Array[CardInstance]
					
					for c in request.card_options:
						if c.is_creature():
							if c.owner == GameState.opponent_of(_ai_player()):
								opponent_creatures.append(c)
							else:
								owned_creatures.append(c)
					
					#Sort by strongest
					opponent_creatures.sort_custom(func(a:CardInstance,b:CardInstance):
						return (a.get_attack()+a.get_endurance()) > (b.get_attack()+b.get_endurance())
					)
					
					#Sort by weakest
					owned_creatures.sort_custom(func(a:CardInstance,b:CardInstance):
						return (a.get_attack()+a.get_endurance()) < (b.get_attack()+b.get_endurance())
					)
					
					for c in opponent_creatures:
						selected.append(c)
						if _is_selection_full(selected,request): return selected
						
					for c in owned_creatures:
						selected.append(c)
						if _is_selection_full(selected,request): return selected
					
					if selected.size() < request.min_count:
						return _brute_choice(request)
					
					return selected
				ChoiceContext.Intent.BUFF:
					##Buff effect heuristics:
					#	Buff strongest owned creatures first
					#	Buff weakest opponents creatures
					#	Randomize if failed
					var selected : Array[CardInstance] = []
					
					var opponent_creatures : Array[CardInstance] = []
					var owned_creatures : Array[CardInstance]
					
					for c in request.card_options:
						if c.is_creature():
							if c.owner == GameState.opponent_of(_ai_player()):
								opponent_creatures.append(c)
							else:
								owned_creatures.append(c)
					
					#Sort by strongest
					opponent_creatures.sort_custom(func(a:CardInstance,b:CardInstance):
						return (a.get_attack()+a.get_endurance()) < (b.get_attack()+b.get_endurance())
					)
					
					#Sort by weakest
					owned_creatures.sort_custom(func(a:CardInstance,b:CardInstance):
						return (a.get_attack()+a.get_endurance()) > (b.get_attack()+b.get_endurance())
					)
					
					for c in owned_creatures:
						selected.append(c)
						if _is_selection_full(selected,request): return selected
					
					for c in opponent_creatures:
						selected.append(c)
						if _is_selection_full(selected,request): return selected
						
					if selected.size() < request.min_count:
						return _brute_choice(request)
					
					return selected
				ChoiceContext.Intent.DEBUFF:
					##DeBuff effect heuristics:
					#	DeBuff strongest opponents creatures first
					#	DeBuff weakest owned creatures
					#	Randomize if failed
					var selected : Array[CardInstance] = []
					
					var opponent_creatures : Array[CardInstance] = []
					var owned_creatures : Array[CardInstance]
					
					for c in request.card_options:
						if c.is_creature():
							if c.owner == GameState.opponent_of(_ai_player()):
								opponent_creatures.append(c)
							else:
								owned_creatures.append(c)
					
					#Sort by strongest
					opponent_creatures.sort_custom(func(a:CardInstance,b:CardInstance):
						return (a.get_attack()+a.get_endurance()) > (b.get_attack()+b.get_endurance())
					)
					
					#Sort by weakest
					owned_creatures.sort_custom(func(a:CardInstance,b:CardInstance):
						return (a.get_attack()+a.get_endurance()) < (b.get_attack()+b.get_endurance())
					)
					
					for c in opponent_creatures:
						selected.append(c)
						if _is_selection_full(selected,request): return selected
						
					for c in owned_creatures:
						selected.append(c)
						if _is_selection_full(selected,request): return selected
					
					if selected.size() < request.min_count:
						return _brute_choice(request)
					
					return selected
				ChoiceContext.Intent.SACRIFICE:
					##Sacrifice effect heuristics:
					#	Sacrifice weakest owned cards first
					var selected : Array[CardInstance] = []
					
					var options : Array[CardInstance] = request.card_options
					
					options.sort_custom(func(a:CardInstance,b:CardInstance):
						if a.is_spell(): return true
						elif b.is_spell(): return false
						else:
							return (a.get_attack()+a.get_endurance()) < (b.get_attack()+b.get_endurance()))
					
					for c in options:
						selected.append(c)
						if _is_selection_full(selected,request): return selected
					
					return selected
				ChoiceContext.Intent.DISCARD:
					##Discard effect heuristics:
					#	Discard weakest owned cards first
					var selected : Array[CardInstance] = []
					
					var options : Array[CardInstance] = request.card_options
					
					options.sort_custom(func(a:CardInstance,b:CardInstance):
						if a.is_spell(): return true
						elif b.is_spell(): return false
						else:
							return (a.get_attack()+a.get_endurance()) < (b.get_attack()+b.get_endurance()))
					
					for c in options:
						selected.append(c)
						if _is_selection_full(selected,request): return selected
					
					return selected
				_:
					return _brute_choice(request)
		_: return _brute_choice(request)

func _is_selection_full(selection : Array, request : ChoiceRequest) -> bool:
	return selection.size() >= request.max_count

#take as many options as allowed
func _brute_choice(request: ChoiceRequest) -> Array:
	var selected: Array = request.options.slice(0, request.max_count)
	return selected
