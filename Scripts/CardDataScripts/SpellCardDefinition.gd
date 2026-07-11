class_name SpellCardDefinition extends CardDefinition

enum CastType {INSTANT, PERSISTENT}

@export var cast_type: CastType = CastType.INSTANT
