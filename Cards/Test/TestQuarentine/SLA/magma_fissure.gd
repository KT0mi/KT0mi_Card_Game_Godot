extends SpellCardDefinition

func _init() -> void:
	id = &"magma_fissure"
	card_name = "Magma Fissure"
	card_text = "This counts as a 'Magma Fissure' card. Choose 1 lane: Deal 1+1 damage to all cards there, if any card was killed, deal 1 damage to the player"
	gate = CardGate.BasicGate(20)
	cast_type = CastType.INSTANT
	sets = ["test_set"]

func get_display_text(instance: CardInstance, _context : bool = false) -> String:
	return "Choose 1 lane: Deal %s+%s damage to all cards there, if any card was killed, deal %s damage to the player" \
		% CardText.dynamic(CheckSystem.effect_damage_of(instance, 1))

func resolve_effect(_card: CardInstance, _event: PlayCardEvent) -> void:
	pass
	
