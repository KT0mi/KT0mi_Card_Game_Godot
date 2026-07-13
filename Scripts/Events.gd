class_name Events extends RefCounted

#Phase and Turn Events
const START_PHASE_START = &"on_start_phase_start"
const START_PHASE_END = &"on_start_phase_end"
const DRAW_PHASE_START = &"on_draw_phase_start"
const DRAW_PHASE_END = &"on_draw_phase_end"
const PLAY_PHASE_START = &"on_play_phase_start"
const PLAY_PHASE_END = &"on_play_phase_end"
const BATTLE_PHASE_START = &"on_battle_phase_start"
const BATTLE_PHASE_END = &"on_battle_phase_end"
const END_PHASE_START = &"on_end_phase_start"
const END_PHASE_END = &"on_end_phase_end"

##Zone Change Event
#This event only triggers when a card has changed zones after the zone change
#was validated and resolved
const ZONE_CHANGE = &"on_zone_change"

##Game Actions Events
const PLAY_CARD_REQUEST = &"on_play_card_request"
const CARD_PLAYED = &"on_card_played"
#Triggered when a card tries to attack a target
const ATTACK_REQUEST = &"on_attack_request"
const ATTACK_RESOLVED = &"on_attack_resolved"
#Triggered when a kill card request is made
const KILL_REQUEST = &"on_kill_request"
const KILL_RESOLVED = &"on_kill_resolved"

##Pipeline Events
#These are specific events that happen at the start/during/after a game pipeline
#A pipeline is a method that changes a variable in game and is subject to
#Modification
const DAMAGE_DEALT = &"on_damage_dealt"
