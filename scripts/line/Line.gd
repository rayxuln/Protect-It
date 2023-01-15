extends Area2D

@export var force := 1000
@export var up_line_color:Gradient
@export var down_line_color:Gradient

@onready var line_2d := %Line2D as Line2D
@onready var collision := %CollisionPolygon2D as CollisionPolygon2D

var normal := Vector2.UP
var line_w := 0.0
var line_d := -1

#----- Methods -----
func gen_line(begin:Vector2, end:Vector2, count:int):
	var d := end - begin
	var step := d / count
	line_w = d.length()
	line_d = d.x == 1 if d.x == 0 else sign(d.x)
	for i in count:
		var pos = Vector2(0, randf_range(-2, 2)) + begin + i*step
		line_2d.add_point(line_2d.to_local(pos))
	
	var p := collision.polygon
	p[0] = collision.to_local(begin)
	p[1] = collision.to_local(end)
	collision.polygon = p
	
	normal = calc_normal(begin, end)
	if normal.y > 0:
		line_2d.gradient = up_line_color
	else:
		line_2d.gradient = down_line_color
	
	

func calc_normal(begin:Vector2, end:Vector2):
	var v := begin - end
	return Vector2(-v.y, v.x).normalized()
	
#----- Signals -----
func _on_line_body_entered(body):
	if body.is_in_group('ball'):
		var w:float = get_viewport().content_scale_size.x
		var f = force * line_w/w
		body.linear_velocity = Vector2.ZERO
		body.apply_impulse(line_d * normal * f, Vector2(randf_range(-2, 2), randf_range(-2, 2)))
		body.play_bounce_effect_at(body.global_position)
		queue_free()

