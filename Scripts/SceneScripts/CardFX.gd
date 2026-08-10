extends Control

@onready var dazed_fx: AnimatedSprite2D = $DazedFX

func _ready() -> void:
	dazed_fx.play()

func get_active_fx(card : CardInstance) -> void:
	dazed_fx.visible = card.get_flag(CardKeywords.DAZED) and card.current_zone == Zone.Type.ARENA
