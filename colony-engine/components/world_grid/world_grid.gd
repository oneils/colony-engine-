extends Node2D

  # ┌─────────────────────┬──────────────┐
  # │ Element             │ Color        │
  # ├─────────────────────┼──────────────┤
  # │  bg                 │ #1e2433      │
  # │ Empty Cell          │ #252d3d      │
  # │ Visited             │ #2d4a2d      │
  # │ Path                │ #3a6b3a      │
  # │ Wall                │ #5c3318      │
  # │ A* path line        │ #40d080      │
  # │ NPC                 │ #e8b830      │
  # │ Target              │ #e84040      │
  # └─────────────────────┴──────────────┘


# walls padding vertically and horizontally
const WALLS_PADDING = 6
const CELL_PADDING = 3

var _config: GridConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ServerClient.config_fetched.connect(_on_config_fetched)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_config_fetched(config: GridConfig):
	_config = config
	queue_redraw()

func _draw():
	if _config == null:
		return
	
	var screen_size = get_viewport_rect().size
	var width = (screen_size.x  - 2 * WALLS_PADDING -  (_config.width - 1) * CELL_PADDING) / _config.width
	var height = (screen_size.y - 2 * WALLS_PADDING - (_config.height - 1) * CELL_PADDING) / _config.height

	var pos_x = WALLS_PADDING
	var pos_y = WALLS_PADDING
	for w in  range(_config.width):
		pos_y = WALLS_PADDING 
		
		for h in range(_config.height):
			draw_rect(Rect2(pos_x, pos_y, width, height), Color.html("#252d3d"), true, 1, false)
			pos_y = pos_y + height + CELL_PADDING
		pos_x = pos_x + width + CELL_PADDING

