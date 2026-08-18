class_name DamageProjectile extends Node2D

@export var radius: float = 12.0
@export var color: Color = Color(1.0, 0.85, 0.2)

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)

func fly_to(target_pos: Vector2, duration: float = 0.35) -> void:
	rotation = (target_pos - global_position).angle()
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_pos, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
