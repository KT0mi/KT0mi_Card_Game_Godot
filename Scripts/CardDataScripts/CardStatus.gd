class_name CardStatus extends RefCounted
#This class stores StringName vars into constants for common use flags and counters
#For cards. I consider these "statuses" like "dazed" when a card is added to the arena.
#Because any card could have them since they are tied to Game State actions 
#and not specific card actions

## ------ Flags ------

const DAZED := &"dazed"
