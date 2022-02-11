extends Node2D


@export_node_path var ball_np

@export_node_path var bg_1_np
@export_node_path var bg_2_np
@export_node_path var bg_3_np

@export_node_path var wall_np

func _physics_process(delta):
	var ball = get_ball()
	if ball:
		global_position = ball.global_position

func _process(delta):
	var screen_h = get_viewport().content_scale_size.y
	var yi = floor(global_position.y / screen_h)
	
	var bg_1:Node2D = get_node(bg_1_np)
	var bg_2:Node2D = get_node(bg_2_np)
	var bg_3:Node2D = get_node(bg_3_np)
	
	bg_1.global_position.y = (yi-1) * screen_h
	bg_2.global_position.y = yi * screen_h
	bg_3.global_position.y = (yi+1) * screen_h
	
	var wall:Node2D = get_node(wall_np)
	
	wall.global_position.y = yi * screen_h
	
	
#----- Methods -----
func get_ball() -> Node2D:
	return get_node_or_null(ball_np)




