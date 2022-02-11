extends Area2D


func _ready() -> void:
	$AnimationPlayer.playback_speed = randf_range(0.1, 1.0)

#----- Methods -----

#----- Signals -----
func _on_saw_body_entered(body: Node2D) -> void:
	if body.is_in_group('ball'):
		body.die('REASON_2')
