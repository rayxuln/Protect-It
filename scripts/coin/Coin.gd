extends Area2D

@export var health_value := 50.0

#----- Methods -----

#----- Signals -----
func _on_coin_body_entered(body: Node2D) -> void:
	if body.is_in_group('ball'):
		body.eat(self)
		queue_free()
