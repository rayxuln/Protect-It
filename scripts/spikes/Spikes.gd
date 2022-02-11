extends Area2D



#----- Signals -----
func _on_spikes_body_entered(body: Node2D) -> void:
	if body.is_in_group('ball'):
		body.die('REASON_1')
