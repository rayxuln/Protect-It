extends Node2D

@export var point_count := 4

@export var up_line_color:Gradient
@export var down_line_color:Gradient

@export_node_path var camera_np
@export var line_prefab:PackedScene

var dragging := false
var line_begin_pos := Vector2.ZERO

@onready var line_2d := $Line2D

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				line_begin_pos = get_local_mouse_position()
				line_2d.visible = true
			else:
				dragging = false
				line_2d.visible = false
				var cam:Camera2D = get_node(camera_np)
				var cam_pos := cam.get_screen_center_position() - Vector2(get_viewport().content_scale_size/2)
				remove_all_lines()
				create_line_at(
					to_global(line_begin_pos)+cam_pos,
					get_global_mouse_position()+cam_pos
					)
				

func _process(delta):
	if dragging:
		gen_line()
#----- Methods -----
func gen_line():
	var line_end_pos = get_local_mouse_position()
	var step = (line_end_pos - line_begin_pos) / point_count
	while line_2d.get_point_count() > point_count:
		line_2d.remove_point(0)
	while line_2d.get_point_count() < point_count:
		line_2d.add_point(Vector2.ZERO)
	for i in point_count:
		var pos = Vector2(0, randf_range(-2, 2)) + line_begin_pos + i*step
		line_2d.set_point_position(i, line_2d.to_local(pos))
	
	var n = calc_normal(line_begin_pos, line_end_pos)
	if n.y > 0:
		line_2d.gradient = up_line_color
	else:
		line_2d.gradient = down_line_color

func create_line_at(begin, end):
	var l = line_prefab.instantiate()
	GameSystem.get_world().add_child(l)
	l.global_position = Vector2.ZERO
	l.gen_line(begin, end, point_count)

func remove_all_lines():
	for l in get_tree().get_nodes_in_group('line'):
		l.queue_free()

func calc_normal(begin:Vector2, end:Vector2):
	var v := begin - end
	return Vector2(-v.y, v.x).normalized()
