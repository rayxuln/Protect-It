extends RigidDynamicBody2D

@export var height_health_factor := 1.3
@export var max_health:float = 100
var health:float = max_health

enum {
	Alive,
	Dead
}

var state = Alive

func _process(delta):
	GameSystem.update_max_height(get_height())

#----- Methods -----
func update_health():
	health -= atan(get_height()) * height_health_factor
	update_apearance()
	if state == Alive and health <= 0:
		die('REASON_0')

func update_apearance():
	var r = health / max_health
	modulate.g = r
	modulate.b = r

func get_height():
	return abs(min(global_position.y, 0))

func die(reason:String):
	var e = GameSystem.fetch_pool('DieEffect')
	GameSystem.get_world().add_child(e)
	e.global_position = global_position
	e.finished_callback = func (): 
		await GameSystem.get_tree().create_timer(1.0).timeout
		GameSystem.call_deferred('you_lose', reason)
	state = Dead
	queue_free()

func eat(obj):
	if obj.is_in_group('coin'):
		health += obj.health_value
		health = min(max_health, health)
		GameSystem.set_score(GameSystem.score+1)
		update_apearance()
		GameSystem.play_sound('collect_coin')

func play_bounce_effect_at(pos:Vector2):
	var e = GameSystem.fetch_pool('BounceEffect')
	GameSystem.get_world().add_child(e)
	e.global_position = pos
#----- Signals -----
func _on_health_timer_timeout() -> void:
	update_health()


func _on_ball_body_entered(body: Node) -> void:
	play_bounce_effect_at(global_position)
