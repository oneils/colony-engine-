extends Node2D

func _ready() -> void:
	var error_display = preload("res://components/error_display.gd").new()
	add_child(error_display)
	ServerClient.request_failed.connect(error_display.show_error)
	ServerClient.request_succeeded.connect(error_display.hide_error)
