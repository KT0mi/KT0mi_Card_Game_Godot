extends CreatureCardDefinition

func _init() -> void:
	id = &"maui_trickster_hero"
	card_name = "Maui: The Trickster Hero"
	card_text = "At the start of your Draw Phase: X is a random number between 0 and 3. All 'Magma Burst' cards do X damage."
	is_special = true
	gate = CardGate.BasicGate(20)
	attack = 4
	endurance = 3
	sets = ["fiery_tradition"]
	
const DAMAGE_COUNTER := &"mth_damage"

func _build_abilities() -> Array[Ability]:
	return [
		Ability.new(
			Events.PLAY_CARD_RESOLVED,
			func(c:CardInstance,_e): c.set_counter(DAMAGE_COUNTER, randi_range(0,3)),
			func(c:CardInstance,e:PlayCardEvent) -> bool: return e.card == c
		),
		Ability.new(
			Events.DRAW_PHASE_START,
			func(c:CardInstance,_e): c.set_counter(DAMAGE_COUNTER, randi_range(0,3)),
			func(c:CardInstance,e:PhaseEvent) -> bool: return e.player == c.owner
		)
	]

func _build_continuous_effects() -> Array[ContinuousEffect]:
	return [
		ContinuousEffect.new(
			ContinuousEffect.Kind.EFFECT_DAMAGE,
			func(_src:CardInstance,dc:CardInstance) -> bool:
				return  dc.definition.damage_tags.has(&"magma_burst"),
			func(_v: int, src:CardInstance) -> int:
				return src.get_counter(DAMAGE_COUNTER),
			ContinuousEffect.Layer.SET
		)
	]
