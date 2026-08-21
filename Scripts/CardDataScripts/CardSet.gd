class_name CardSet extends Resource

@export var id: StringName
@export var display_name: String
@export var description: String = ""
@export var is_private: bool = false

@export var card_border: Texture2D
@export var card_text_rect: Texture2D
@export var special_card_border: Texture2D
@export var special_card_text_rect: Texture2D

## Room to grow: set symbol, release date, booster pack art defaults, etc.
@export var set_icon: Texture2D
