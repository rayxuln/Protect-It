extends Node

@export var coin_prefab:PackedScene
@export var upper_range:float = -1.5

var current_max_height:float = -1

#----- Methods -----
func gen_a_coin():
	var w:float = get_viewport().content_scale_size.x
	var h:float = get_viewport().content_scale_size.y
	
	var upper := upper_range * h
	
	var c = coin_prefab.instantiate()
	GameSystem.get_world().add_child(c)
	c.global_position.x = randf_range(0, w)
	c.global_position.y = -current_max_height + upper + randf_range(upper, 0)
#----- Signals -----
func _on_timer_timeout() -> void:
	if current_max_height < GameSystem.max_height:
		current_max_height = GameSystem.max_height + 400
		var num = randi_range(1, 2)
		for i in num:
			gen_a_coin()
