extends Node


func _ready() -> void:
	GameSystem.get_gui_root().hide()
	await get_tree().create_timer(0.5).timeout
	GameSystem.get_gui_root().show()
	GameSystem.get_gui('StartMenu').show()

#----- Methods -----
func load_world():
	var w = preload('res://scenes/World.tscn').instantiate()
	add_child(w)
	GameSystem.game_started.emit()
