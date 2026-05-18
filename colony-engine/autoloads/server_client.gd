extends Node

# const SERVER_URL = "http://localhost:8080/npcs/state"


var SERVER_URL: String
const STATE_URL = "/npcs/state"


signal state_updated(npcs: Array)
signal request_failed(message: String)
signal request_succeeded()

var http_request: HTTPRequest

func _ready() -> void:
	SERVER_URL = ProjectSettings.get_setting("application/config/server_url", "http://localhost:8080")
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	_fetch_state()

func _fetch_state() -> void:
	var error = http_request.request(SERVER_URL + STATE_URL)
	if error != OK:
		request_failed.emit("can't reach server")

func _on_request_completed(result, response_code, _headers, body) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		request_failed.emit("server unavailable (code %d)" % response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if not json or not json.has("npcs"):
		request_failed.emit("invalid server response")
		return

	request_succeeded.emit()
	state_updated.emit(json["npcs"])

	await get_tree().create_timer(0.1).timeout
	_fetch_state()
