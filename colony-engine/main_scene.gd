extends Node2D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)

	timer.wait_time = 0.5 # 500ms
	timer.timeout.connect(_fetch_state)
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _fetch_state():
	print("Fetching the state")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	var error = http_request.request("http://localhost:8080/state")
	if error != OK:
		push_error("Can't performe HTTP request")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	# print(json["status"])
	print(response_code)
	print(json)
