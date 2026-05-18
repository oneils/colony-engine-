extends Node

# const server_url = "http://localhost:8080/npcs/state"


const STATE_URL = "/npcs/state"
const CFG_URL = "/game/config"

var server_url: String


signal state_updated(npcs: Array)
signal request_failed(message: String)
signal request_succeeded()

# succefully fetched and process CFG response from server
signal config_fetched(config: GridConfig)

var http_request: HTTPRequest
var cfg_request: HTTPRequest

func _ready() -> void:
	
	server_url = ProjectSettings.get_setting("application/config/server_url", "http://localhost:8080")
	cfg_request = HTTPRequest.new()
	add_child(cfg_request)
	cfg_request.request_completed.connect(_on_cfg_request_completed)
	_fetch_config()

	# fetch the NPCs state
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	_fetch_state()

func _on_cfg_request_completed(result, response_code, _headers, body) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		request_failed.emit("server unavailable (code %d)" % response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if not json or not json.has("grid"):
		request_failed.emit("invalid server response. There is no GRID config")
		return

	var cfg := GridConfig.new()
	cfg.width = json["grid"]["width"]
	cfg.height = json["grid"]["height"]

	config_fetched.emit(cfg)
	request_succeeded.emit()

func _fetch_config():
	var error = cfg_request.request(server_url + CFG_URL)
	if error != OK:
		request_failed.emit("can't fetch game configs from server")

func _fetch_state() -> void:
	var error = http_request.request(server_url + STATE_URL)
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

