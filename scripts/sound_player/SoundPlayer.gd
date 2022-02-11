extends AudioStreamPlayer



#----- Methods -----
func refresh():
	stream = null

func recycle():
	stop()

func play_sound(s, pitch_range := [1, 1]):
	if s is Array:
		stream = load(s[randi()%s.size()])
	else:
		stream = load(s)
	pitch_scale = randf_range(pitch_range[0], pitch_range[1])
	play()

#----- Signals -----
func _on_sound_player_finished() -> void:
	GameSystem.recycle_pool(self)
