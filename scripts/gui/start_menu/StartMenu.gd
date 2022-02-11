extends Control

@onready var sound_button := $VBoxContainer/HBoxContainer/SoundButton
@onready var music_button := $VBoxContainer/HBoxContainer/MusicButton

#----- Methods -----
func on_show():
	update_button_text()

func update_button_text():
	sound_button.text = tr('SOUND_BUTTON') % [tr('on' if GameSystem.enable_sound else 'off')]
	music_button.text = tr('MUSIC_BUTTON') % [tr('on' if GameSystem.enable_music else 'off')]
#----- Signals -----
func _on_quit_button_pressed() -> void:
	GameSystem.play_sound('button_click')
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()


func _on_how_button_pressed() -> void:
	GameSystem.play_sound('button_click')
	$HowDialog.popup_centered()


func _on_start_button_pressed() -> void:
	GameSystem.play_sound('button_click')
	GameSystem.restart()


func _on_leader_board_button_pressed() -> void:
	GameSystem.play_sound('button_click')
	GameSystem.get_gui('LeaderBoardView').show()


func _on_setting_button_pressed() -> void:
	GameSystem.play_sound('button_click')
	GameSystem.get_gui('SettingView').show()


func _on_start_menu_visibility_changed() -> void:
	if is_visible_in_tree():
		on_show()


func _on_sound_button_pressed() -> void:
	GameSystem.enable_sound = not GameSystem.enable_sound
	GameSystem.save_savedata()
	GameSystem.play_sound('button_click')
	update_button_text()


func _on_music_button_pressed() -> void:
	GameSystem.enable_music = not GameSystem.enable_music
	GameSystem.save_savedata()
	GameSystem.play_sound('button_click')
	update_button_text()
