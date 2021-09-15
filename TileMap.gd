extends TileMap

export var cursor_position:Vector2;

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		cursor_position = world_to_map(child.position)

func request_move(pawn, direction):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	return update_cursor_position(pawn, cell_start, cell_target)

func update_cursor_position(pawn, cell_start, cell_target):
	cursor_position = cell_target
	return get_global_cursor()

func get_global_cursor():
	return map_to_world(cursor_position) + cell_size/2
