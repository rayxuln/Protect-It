extends Node2D

var finished_callback

enum {
	Refresh,
	Ready,
	Dead,
}
var state = Refresh

enum EffectType {
	Explode = 0,
	Bounce,
}
@export_enum(Explode, Bounce) var effect_type

func _process(delta: float) -> void:
	if state == Refresh:
		$GPUParticles2D.restart()
		if effect_type == EffectType.Explode:
			GameSystem.play_sound('explode')
		elif effect_type == EffectType.Bounce:
			GameSystem.play_sound(['bounce_1', 'bounce_2', 'bounce_3'])
		state = Ready
	elif state == Ready and not $GPUParticles2D.emitting:
		if finished_callback:
			finished_callback.call()
		GameSystem.recycle_pool(self)
		state = Dead

func refresh():
	state = Refresh
	finished_callback = null
