class_name CardDefinition extends Resource

@export var id: StringName
@export var card_name: String
@export var card_text: String
@export var is_special: bool = false
@export var sets: Array[StringName] = []
@export var art: Texture2D

func get_abilities() -> Array[Ability]:
	return []
