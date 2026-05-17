extends Node2D

var current_positions: Dictionary = {}
var target_positions: Dictionary = {}

func _ready() -> void:
	ServerClient.state_updated.connect(_on_state_updated)

func _process(delta: float) -> void:
	var changed = false
	for id in target_positions:
		var target = target_positions[id]
		var current = current_positions.get(id, target)
		current_positions[id] = current.move_toward(target, 80.0 * delta)
		changed = true
	if changed:
		queue_redraw()

func _draw() -> void:
	for id in current_positions:
		draw_circle(current_positions[id], 15, Color.WHITE)

func _on_state_updated(npcs: Array) -> void:
	for npc in npcs:
		var id = str(npc["id"])
		target_positions[id] = Vector2(npc["position"]["x"], npc["position"]["y"])
