extends Control

var address := 'http://localhost:33445'
var data_url := '%s/data' % address

var data

@onready var get_http := $GetHTTPRequest
@onready var post_http := $PostHTTPRequest

@onready var data_tree:Tree = $DataTree

func _ready() -> void:
	data = null
	data_tree.set_column_title(0, tr('Player Name'))
	data_tree.set_column_title(1, tr('Score'))

#----- Methods -----
func on_show():
	post_data()
	fetch_data()
	
func fetch_data():
	get_http.cancel_request()
	var err = get_http.request(data_url)
	$LoadingLabel.show()
	if err != OK:
		GameSystem.alert(tr('ERROR_1') % err)
		$LoadingLabel.hide()
		return

func update_data_tree():
	data_tree.clear()
	if data == null:
		return
	data.sort_custom(func (a, b): return a[1] > b[1])
	
	var current:TreeItem = null
	
	var root = data_tree.create_item()
	for d in data:
		var playername = d[0]
		var score = d[1]
		var item:TreeItem = data_tree.create_item(root)
		item.set_text(0, playername)
		item.set_text(1, str(score))
		if playername == GameSystem.get_username():
			current = item
			GameSystem.update_best_score(score, false)
	if current:
		current.select(0)
		data_tree.scroll_to_item(current)

func post_data():
	post_http.cancel_request()
	var json = JSON.new()
	var d = {
		'pwd': GameSystem.password,
		'data': {GameSystem.get_username(): GameSystem.best_score},
	}
	var pd := {
		'p': Marshalls.raw_to_base64(json.stringify(d).to_utf8_buffer()),
	}
	var err = post_http.request(
		data_url,
		['Content-Type: application/json'],
		true,
		HTTPClient.METHOD_POST,
		json.stringify(pd)
		)
	if err != OK:
		GameSystem.alert(tr('ERROR_3') % err)
		return
#----- Signals -----
func _on_leader_board_view_visibility_changed() -> void:
	if is_visible_in_tree():
		on_show()


func _on_back_button_pressed() -> void:
	GameSystem.play_sound('button_click')
	hide()


func _on_get_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	$LoadingLabel.hide()
	if result != HTTPRequest.RESULT_SUCCESS and response_code != 200 and response_code != 304:
		GameSystem.alert(tr('ERROR_4') % [result, response_code])
		return
	var json = JSON.new()
	var err = json.parse(body.get_string_from_utf8())
	if err != OK:
		GameSystem.alert(tr('ERROR_2') % err)
		return
	data = json.get_data()
	print(data)
	update_data_tree()
	for kv in data:
		if kv[0] == GameSystem.get_username():
			GameSystem.update_best_score(kv[1], false)
		


func _on_post_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS and response_code != 200 and response_code != 304:
		GameSystem.alert(tr('ERROR_5') % [result, response_code])
		return
	fetch_data()
