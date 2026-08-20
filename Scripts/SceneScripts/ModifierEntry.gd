class_name ModifierEntry extends Control

@onready var kind_label : Label = $ModifierContainer/NamesContainer/KindLabel
@onready var source_label : Label = $ModifierContainer/NamesContainer/SourceLabel
@onready var modifier_label : Label = $ModifierContainer/ValuesContainer/ModifierLabel
@onready var new_value_label : Label = $ModifierContainer/ValuesContainer/NewValueLabel

@export var kind_text : String = "":
	set(s): kind_label.text = s
@export var source_text : String = "":
	set(s): source_label.text = s
@export var modifier_text : String = "":
	set(s): modifier_label.text = s
@export var new_value_text : String = "":
	set(s): new_value_label.text = s
