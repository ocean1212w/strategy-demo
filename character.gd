extends Position2D

export(float) var SPEED = 400.0

enum STATES { IDLE, READY, FOLLOW }
enum PopupIds {
	WAIT
	CANCEL
	TALK1
	TALK2
	TALK3
	TALK4
	PLANT
	HARVEST
	ITEMS
}
var _state = null

var path = []
var target_point_world = Vector2()
var target_position = Vector2()
var previous_position = Vector2()

var velocity = Vector2()

var max_movement = 8
var moved = false
var selected = false
var items = []

onready var _pm = $PopupNode/PopupMenu
onready var _cursor_grid = get_parent().get_parent()
onready var _tile_grid = _cursor_grid.get_parent()
onready var _cursor = _cursor_grid.get_node("Cursor")
onready var _plant_factory = _cursor_grid.get_node("PlantFactory")

func _ready():
	_change_state(STATES.IDLE)
	get_node("Sprite").modulate = Color(0.8,0.8,0.8,0.8)
	_default_pm()
	_pm.connect("id_pressed", self, "_popup_selected")
	_cursor_grid.set_cellv(_cursor_grid.world_to_map(position), 1)


func _change_state(new_state):
	if new_state == STATES.READY:
		path = _tile_grid.find_path(position, target_position, max_movement, false)
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return
		if len(path) < max_movement + 2 and _cursor_grid.is_cell_empty(target_position):
			target_point_world = path[1]
		else:
			_change_state(STATES.IDLE)
			return
	_state = new_state
	if new_state == STATES.FOLLOW:
		_cursor_grid.set_cellv(_cursor_grid.world_to_map(position), -1)
		_cursor_grid.set_cellv(_cursor_grid.world_to_map(target_position), 1)


func _process(delta):
	var current_tile = _tile_grid.world_to_map(position)
	if not _state == STATES.FOLLOW:
		_cursor_grid.set_cellv(current_tile, 1)
		if _state == STATES.READY:
			get_node("Sprite").modulate = Color(1,1,1,0.8)
		return
	moved = true
	selected = false
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		if len(path) == 0:
			var adjacent_characters = _cursor_grid.find_adjacents(position)
			var adjacent_cells = _tile_grid.find_adjacent_cell_values(position)
			var talk_options = [PopupIds.TALK1, PopupIds.TALK2, PopupIds.TALK3, PopupIds.TALK4]
			for character in adjacent_characters:
				var option = talk_options[0]
				talk_options.pop_front()
				_pm.add_item("Talk to " + character.name, option)
				_pm.set_item_metadata(option, character)
			if _tile_grid.get_cellv(_tile_grid.world_to_map(position)) == 3:
				var planted = false
				for child in _plant_factory.get_children():
					if child.position.distance_to(position) < 20:
						planted = true
						if child.grown:
							_pm.add_item("Harvest", PopupIds.HARVEST)
							_pm.set_item_metadata(PopupIds.HARVEST, child)
				if not planted:
					_pm.add_item("Plant here", PopupIds.PLANT)
			_pm.popup(Rect2(target_point_world, _pm.rect_size))
			_change_state(STATES.IDLE)
			return
		target_point_world = path[0]


func move_to(world_position):
	var MASS = 10.0
	var ARRIVE_DISTANCE = 10.0
	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	position += velocity * get_process_delta_time()
	rotation = velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE
	
	
func draw_path():
	if selected:
		target_position = _cursor_grid.get_global_cursor()
		_change_state(STATES.READY)


func _input(event):
	if event is InputEventKey and not moved and selected:
		if event.pressed and event.scancode == KEY_SPACE and _state == STATES.READY:
			previous_position = position
			_cursor_grid.set_cellv(_cursor_grid.world_to_map(position), -1)
			_change_state(STATES.FOLLOW)
			_cursor.pause_cursor()

func _on_End_Turn_pressed():
	moved = false
	selected = false
	get_node("Sprite").modulate = Color(0.8,0.8,0.8,0.8)
	_default_pm()
	 

func _popup_selected(id):
	if id == PopupIds.WAIT:
		get_node("Sprite").modulate = Color(0.5,0.5,0.5,0.5)
	if [PopupIds.TALK1, PopupIds.TALK2, PopupIds.TALK3, PopupIds.TALK4].has(id):
		var character = _pm.get_item_metadata(id)
		get_node("Sprite").modulate = Color(0.5,0.5,0.5,0.5)
	if id == PopupIds.PLANT:
		_plant_factory.spawn_plant(position)
		get_node("Sprite").modulate = Color(0.5,0.5,0.5,0.5)
	if id == PopupIds.HARVEST:
		for child in _plant_factory.get_children():
			if child.position.distance_to(position) < 20:
				_plant_factory.remove_child(child)
				items.append('plant')
				get_node("Sprite").modulate = Color(0.5,0.5,0.5,0.5)
				get_node('/root/Game').add_points(1)
	if id == PopupIds.CANCEL:
		moved = false
		selected = false
		position = previous_position
		_cursor.position = previous_position
		_cursor_grid.update_cursor_position(previous_position)
	if id == PopupIds.ITEMS:
		print(items)
	_tile_grid.clear_path()
	_cursor.unpause_cursor()		

func _default_pm():
	_pm.clear()
	_pm.add_item("Inventory", PopupIds.ITEMS)
	_pm.add_item("Wait", PopupIds.WAIT)
	_pm.add_item("Cancel", PopupIds.CANCEL)

