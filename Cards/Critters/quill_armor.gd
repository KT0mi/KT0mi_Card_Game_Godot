extends SpellCardDefinition

func _init() -> void:
	id = &"quill_armor"
	card_name = "Quill Armor"
	gate = CardGate.None()
	cast_type = CastType.PERSISTENT
	sets = [&"critters"]

func get_display_text(instance: CardInstance) -> String:
	return "For the next %s attacks to your player card: If the attacker is a creature card, deal 1 damage to it." % CardText.dynamic(instance.counters.get(ARMOR_KEY, 3))

const ARMOR_KEY := "armor"

func resolve_effect(card: CardInstance, _event: PlayCardEvent) -> void:
	card.set_counter(ARMOR_KEY, 3)

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.ATTACK_RESOLVED,
			_quill_armor_ability,
			_quill_armor_con
		)
	]

func _quill_armor_con(card : CardInstance, event : AttackEvent) -> bool:
	print("quill_armor: Checking effect condition")
	if event.target == card.owner.get_player_card():
		print("quill_armor: Confirmed damage was dealt to the card owner from a creature source")
		return true
	return false

func _quill_armor_ability(card : CardInstance, event : AttackEvent) -> void:
	DamagePipeline.apply_damage(event.attacker, 1, card)
	
	if card.tick_counter(ARMOR_KEY) <= 0:
		#Have to think about this should I do kill card when resolving persistent spells or simply moving them to the graveyard?
		ZoneManager.move_to(card, Zone.Type.GRAVEYARD, ZoneChangeEvent.Reason.RESOLVE)
