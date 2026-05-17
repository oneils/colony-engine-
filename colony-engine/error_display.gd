extends CanvasLayer

var _label: Label

func _ready() -> void:
	_label = Label.new()
	_label.position = Vector2(10, 10)
	_label.add_theme_color_override("font_color", Color.RED)
	add_child(_label)
	visible = false

func show_error(message: String) -> void:
	_label.text = message
	visible = true

func hide_error() -> void:
	visible = false
