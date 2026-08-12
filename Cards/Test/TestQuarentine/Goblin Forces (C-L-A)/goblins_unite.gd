extends SpellCardDefinition

func _init() -> void:
	id = &"goblins_unite"
	card_name = "Goblins! Unite!"
	card_text = "If there are 3 creature cards on the arena, join them together and add a 'Goblin Mecha' to your hand with their stats combined."
	gate = CardGate.BasicGate(15)
	cast_type = CastType.INSTANT
	sets = ["goblin_forces"]

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	if card.owner.arena().size() < 3:
		print("goblins_unite: Effect not resolved. Reason: Not enough arena cards")
		return
	
	var attack_pool : int = 0
	var endurance_pool : int = 0
	
	for c : CardInstance in card.owner.arena().duplicate():
		attack_pool += c.get_attack()
		endurance_pool += c.get_endurance()
		await GameActions.try_kill_card(c)
		
	var gm := await GameActions.try_summon_card(card.owner, &"goblin_mecha", Zone.Type.ARENA, 1)
	GameActions.try_modify_attack(gm, StatModifer.delta(attack_pool, card))
	GameActions.try_modify_endurance(gm, StatModifer.delta(endurance_pool, card))
