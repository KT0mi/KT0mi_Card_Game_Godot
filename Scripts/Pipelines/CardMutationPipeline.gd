extends Node
##Autoload

#Direct stat changes. Damage is seperated as it has specific meaning as damage.

signal card_stats_changed(card: CardInstance)

func modify_attack(card: CardInstance, delta: int) -> void:
	card.current_attack += delta
	card_stats_changed.emit(card)
	
func modify_endurance(card: CardInstance, delta: int) -> void:
	card.current_endurance += delta
	card_stats_changed.emit(card)
