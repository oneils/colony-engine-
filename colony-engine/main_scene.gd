extends Node2D

signal server_error(message: String)
signal server_ok

var current_positions = {}
var target_positions = {}
var http_request: HTTPRequest

func _ready() -> void:
	var error_display = preload("res://error_display.gd").new()
	add_child(error_display)
	server_error.connect(error_display.show_error)
	server_ok.connect(error_display.hide_error)

	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	_fetch_state()

func _process(delta: float) -> void:
	var changed = false
	for id in target_positions:
		var target = target_positions[id]
		var current = current_positions.get(id, target)
		current_positions[id] = current.move_toward(target, 80.0 * delta)
		changed = true
	if changed:
		queue_redraw()

func _fetch_state():
	var error = http_request.request("http://localhost:8080/npcs/state")
	if error != OK:
		push_error("Can't perform HTTP request")

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		server_error.emit("server unavailable (code %d)" % response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if not json or not json.has("npcs"):
		server_error.emit("invalid server response")
		return

	server_ok.emit()
	for npc in json["npcs"]:
		var id = str(npc["id"])
		target_positions[id] = Vector2(npc["position"]["x"], npc["position"]["y"])

	await get_tree().create_timer(0.1).timeout
	_fetch_state()

func _draw():
	for id in current_positions:
		draw_circle(current_positions[id], 15, Color.WHITE)
