extends SpellCardDefinition

func _init() -> void:
	id = &"goblins_unite"
	card_name = "Goblins! Unite!"
	card_text = "If there are 3 creature cards on the arena, join them together and create a 'Goblin Mecha' with their stats combined."
	gate = CardGate.BasicGate(15)
	cast_type = CastType.INSTANT

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	if card.owner.arena().size() < 3:
		print("goblins_unite: Effect not resolved. Reason: Not enough arena cards")
		return
	
	var attack_pool : int = 0
	var endurance_pool : int = 0
	
	for c : CardInstance in card.owner.arena().duplicate():
		attack_pool += c.get_attack()
		endurance_pool += c.get_endurance()
		GameActions.try_kill_card(c)
		
	var gm := CardFactory.create_instance(&"goblin_mecha", card.owner)
	ZoneManager.move_to(gm, Zone.Type.ARENA, ZoneChangeEvent.Reason.SUMMON, 1)
