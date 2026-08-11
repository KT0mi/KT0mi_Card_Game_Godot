extends SpellCardDefinition

func _init() -> void:
	id = &"ambush_tactic"
	card_name = "Ambush Tactic"
	card_text = "Choose any 1 damageable card, then choose 1 creature from your arena that can attack to attack it."
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT
	sets = [&"critters"]
	
func resolve_effect(card: CardInstance, event: PlayCardEvent) -> void:
	var tA : Array = await ChoiceManager.request(
		"Choose any 1 damageable card:",
		Events.EFFECT_TAG,
		GameState.all_cards_in_target_areas(),
		card.owner
	)
	
	var target : CardInstance = tA[0]
	if target == null:
		return
		
	var aA : Array = await ChoiceManager.request(
		"Choose any 1 card from your arena:",
		Events.EFFECT_TAG,
		card.owner.arena().duplicate(),
		card.owner
	)
	
	if aA.is_empty() or aA == null: return
	
	var attacker : CardInstance = aA[0]
	if attacker == null:
		return
	
	GameActions.try_attack(attacker, target)
