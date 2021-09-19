extends TileMap

export var cursor_position:Vector2;
var selected_position;

# Called when the node enters the scene tree for the first time.
func _ready():
	cursor_position = world_to_map(get_node("Cursor").position)

func request_move(pawn, direction):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	if get_parent().is_outside_map_bounds(cell_target):
		return get_global_cursor()
	return update_cursor_position(pawn, cell_start, cell_target)

func update_cursor_position(pawn, cell_start, cell_target):
	cursor_position = cell_target
	return get_global_cursor()

func get_global_cursor():
	return map_to_world(cursor_position) + cell_size/2

func _cursor_check():
	var selected_child
	for child in get_children():
		if child == get_node("Cursor") or child.moved == true:
			continue
		elif child.selected:
			return
		elif world_to_map(child.position) == cursor_position:
			selected_child = child
	if selected_child:
		selected_child.selected = true
			
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			_cursor_check()
