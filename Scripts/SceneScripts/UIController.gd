extends Control

##Buttons
@onready var close_button : Button = $CloseButton

##AnimationPlayer
@onready var animation_player : AnimationPlayer = $UIAnimationPlayer

##Phase UI Variables
@onready var start_phase_spr : Sprite2D = $PhaseLabels/StartPhase
@onready var draw_phase_spr : Sprite2D = $PhaseLabels/DrawPhase
@onready var play_phase_spr : Sprite2D = $PhaseLabels/PlayPhase
@onready var battle_phase_spr : Sprite2D = $PhaseLabels/BattlePhase
@onready var end_phase_spr : Sprite2D = $PhaseLabels/EndPhase

#Scene Refs
const MAIN_SCENE := "res://Scenes/Main.tscn"

func _ready() -> void:
	#Setup Buttons
	close_button.pressed.connect(_on_close_button)
	HoverHandler.register_hover(close_button)
	#Setup signal connections
	TurnController.phase_changed.connect(_on_phase_changed)
	
func _on_close_button() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE)

func _on_phase_changed(phase: TurnController.Phase, player: Player, forgetting:bool) -> void:
	AnimationQueue.enqueue(func() -> void:
		match phase:
			TurnController.Phase.START_TURN:
				start_phase_spr.visible = true
			TurnController.Phase.DRAW:
				draw_phase_spr.visible = true
			TurnController.Phase.PLAY:
				play_phase_spr.visible = true
			TurnController.Phase.BATTLE:
				battle_phase_spr.visible = true
			TurnController.Phase.END_TURN:
				end_phase_spr.visible = true
				
		
		if not forgetting:
			animation_player.play("PhaseLabelTransition",-1, 1.5)
		else:
			animation_player.play("PhaseLabelTransition",-1, 3.0)
			
		await animation_player.animation_finished
		_clear_phase_spr()
		)

func _clear_phase_spr() -> void:
	start_phase_spr.visible = false
	draw_phase_spr.visible = false
	play_phase_spr.visible = false
	battle_phase_spr.visible = false
	end_phase_spr.visible = false
