extends CreatureCardDefinition

func _init() -> void:
	id = &"titan_porcupine"
	card_name = "Titan Porcupine"
	card_text = "Whenever this card attacks deal 1 damage to every other card in the arena."
	gate = CardGate.BasicGate(15)
	attack = 5
	endurance = 5
	sets = ["pantagruel_islet"]

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.ATTACK_RESOLVED,
			func(card:CardInstance,_e:AttackEvent):
				for c in GameState.all_cards_in_arena().duplicate():
					if c == card: continue
					await DamagePipeline.apply_damage(c, CheckSystem.effect_damage_of(card, 1), card, DamageEvent.Reason.CARD_EFFECT),
			func(c:CardInstance,e:AttackEvent)->bool: return e.attacker == c,
		)
	]
