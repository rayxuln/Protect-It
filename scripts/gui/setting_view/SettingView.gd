extends Control



@onready var line_edit := $VBoxContainer/LineEdit
@onready var ok_button := $VBoxContainer/OkButton

#----- Methods -----
func on_show():
	ok_button.disabled = GameSystem.player_name == null
	line_edit.text = '' if GameSystem.player_name == null else GameSystem.get_username()
#----- Signals -----
func _on_line_edit_text_changed(new_text: String) -> void:
	ok_button.disabled = new_text.is_empty()


func _on_ok_button_pressed() -> void:
	GameSystem.play_sound('button_click')
	GameSystem.player_name = line_edit.text
	GameSystem.best_score = 0
	GameSystem.save_savedata()
	hide()


func _on_setting_view_visibility_changed() -> void:
	if is_visible_in_tree():
		on_show()
