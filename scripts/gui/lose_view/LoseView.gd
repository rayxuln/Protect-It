extends Control


#----- Methods -----
func on_show():
	GameSystem.play_sound('game_over')

func set_score(s):
	$PanelContainer/VBoxContainer/ScoreLabel.text = tr('LOSE_SCORE') % [s]

func set_best(s):
	$PanelContainer/VBoxContainer/BestLabel.text = tr('LOSE_BEST') % [s]

func set_reason(s):
	$TitleLabel.text = ('%s, ' % [GameSystem.get_username()]) + tr('you lose')
	$ReasonLabel.text = s
#----- Signals -----
func _on_restart_button_pressed() -> void:
	GameSystem.play_sound('button_click')
	GameSystem.restart()


func _on_back_button_pressed() -> void:
	GameSystem.play_sound('button_click')
	hide()
	GameSystem.get_gui('StartMenu').show()


func _on_lose_view_visibility_changed() -> void:
	if is_visible_in_tree():
		on_show()
