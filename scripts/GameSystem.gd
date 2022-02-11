extends Node

signal game_started

const password := 'you know it!'
const savedata_path := 'meta.sexy'
const sound_path_format := 'res://sounds/%s.ogg'

var score := 0.0
var best_score := 0.0
var max_height := 0.0
var player_name
var enable_sound := true :
	set(v):
		enable_sound = v
		AudioServer.set_bus_mute(AudioServer.get_bus_index('Sounds'), not enable_sound)
var enable_music := true :
	set(v):
		enable_music = v
		AudioServer.set_bus_mute(AudioServer.get_bus_index('Music'), not enable_music)

var pools := {}

func _ready() -> void:
	player_name = null
	load_savedata()
	game_started.connect(self._on_game_started)
	
	init_pool('BounceEffect', load('res://prefabs/BounceEffect.tscn'), 2)
	init_pool('DieEffect', load('res://prefabs/ExplodeEffect.tscn'), 2)
	init_pool('SoundPlayer', load('res://prefabs/SoundPlayer.tscn'), 10)
	
	if player_name == null:
		get_gui('SettingView').call_deferred('show')
#----- Methods -----
func init_pool(n:String, prefab:PackedScene, count:int):
	var pool := []
	for i in count:
		var ins = prefab.instantiate()
		ins.set_meta('pool', n)
		pool.append(ins)
	pools[n] = {
		'pool': pool,
		'prefab': prefab,
	}

func fetch_pool(n:String):
	if not pools.has(n):
		printerr('no pool name %s' % n)
		return null
	var pool:Array = pools[n].pool
	var prefab:PackedScene = pools[n].prefab
	var ins = null
	if pool.size() == 0:
		ins = prefab.instantiate()
		ins.set_meta('pool', n)
	else:
		ins = pool.pop_back()
	if ins.has_method('refresh'):
		ins.refresh()
	return ins

func recycle_pool(obj:Node):
	if not obj.has_meta('pool'):
		printerr('No pool meta data!')
		return
	var n:String = obj.get_meta('pool')
	if not pools.has(n):
		printerr('no pool name %s' % n)
		return
	var pool:Array = pools[n].pool
	if obj.has_method('recycle'):
		obj.recycle()
	if obj.get_parent() != null:
		obj.get_parent().remove_child(obj)
	pool.push_back(obj)

func get_game() -> Node:
	return get_node('/root/Game')

func get_world() -> Node2D:
	return get_node('/root/Game/World')

func get_gui_root() -> Control:
	return get_node('/root/Game/CanvasLayer/Control')

func get_gui(path) -> Node:
	return get_gui_root().get_node(path)

func set_score(s):
	score = s
	
	get_gui('ScoreLabel').text = tr('SCORE') % [score]

func you_lose(reason:String):
	var w = get_world()
	w.get_parent().remove_child(w)
	w.free()
	
	update_best_score(score)
	
	var lose_view = get_gui('LoseView')
	lose_view.set_score(score)
	lose_view.set_best(best_score)
	lose_view.set_reason(reason)
	lose_view.show()

func update_best_score(s, post:=true):
	best_score = max(best_score, s)
	if post:
		get_gui('LeaderBoardView').post_data()
	save_savedata()

func load_savedata():
	var dir := Directory.new()
	dir.open('user://')
	var path:String = ProjectSettings.globalize_path('user://' + savedata_path)
	if not dir.file_exists(path):
		print('Sexy not exists!')
		save_savedata()
		return
	var file := File.new()
	var err := file.open_encrypted_with_pass(path, File.READ, password)
	if err != OK:
		push_error('Can\'t open savedata file at: %s. Code: %s' % [path, err])
		return
	var json := JSON.new()
	err = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error('Can\'t read savedata! Code: %s' % [err])
		return
	var data:Dictionary = json.get_data()
	print('load: ', data)
	if data.has('best_score'):
		best_score = data.best_score
	if data.has('player_name'):
		player_name = data.player_name
	if data.has('enable_sound'):
		enable_sound = data.enable_sound
	if data.has('enable_music'):
		enable_music = data.enable_music
	print('Loaded savedata from: %s' % [path])

func save_savedata():
	var dir := Directory.new()
	var path:String = ProjectSettings.globalize_path('user://' + savedata_path)
	if dir.file_exists(path):
		dir.open('user://')
		dir.remove(path)
	var file := File.new()
	var err := file.open_encrypted_with_pass(path, File.WRITE, password)
	if err != OK:
		push_error('Can\'t open savedata file at: %s. Code: %s' % [path, err])
		return
	var json := JSON.new()
	var d := {
		'best_score': best_score,
		'player_name': player_name,
		'enable_sound': enable_sound,
		'enable_music': enable_music,
	}
	print('save: ', d)
	file.store_string(json.stringify(d))
	file.close()
	print('Save savedata to: %s' % [path])


func restart():
	get_gui('LoseView').hide()
	get_gui('StartMenu').hide()
	get_game().load_world()

func get_ball():
	var b = get_tree().get_nodes_in_group('ball')
	if b.size() == 0:
		return null
	return b[0]

func update_max_height(s):
	max_height = max(max_height, s)

func alert(message, title='Alert'):
	var d:AcceptDialog = get_gui('ErrorDialog')
	d.title = title
	d.dialog_text = message
	d.popup_centered()

func get_username():
	if player_name == null:
		return 'Anonymous'
	return player_name

func play_sound(s, pitch_range := [0.8, 1.2]):
	if s is Array:
		for i in s.size():
			s[i] = sound_path_format % [s[i]]
	else:
		s = sound_path_format % [s]
	var n = fetch_pool('SoundPlayer')
	get_game().add_child(n)
	n.play_sound(s)
#----- Signals -----
func _on_game_started():
	set_score(0)
	max_height = 0
