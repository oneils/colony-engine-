extends Node2D

var current_positions = {}
var target_positions = {}

func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.timeout.connect(_fetch_state)
	timer.start()

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
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	var error = http_request.request("http://localhost:8080/npcs/state")
	if error != OK:
		push_error("Can't perform HTTP request")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	for npc in json["npcs"]:
		var id = str(npc["id"])
		target_positions[id] = Vector2(npc["position"]["x"], npc["position"]["y"])

func _draw():
	for id in current_positions:
		draw_circle(current_positions[id], 15, Color.WHITE)
