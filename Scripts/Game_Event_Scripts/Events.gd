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

#Zone Change Event
#This event only triggers when a card has changed zones after the zone change
#was validated and resolved
const ZONE_CHANGE = &"on_zone_change"

#Game Actions Events
const PLAY_CARD_REQUEST = &"on_play_card_request"
const CARD_PLAYED = &"on_card_played"
