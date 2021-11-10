extends Position2D

export(float) var SPEED = 150.0

enum STATES { IDLE, READY, FOLLOW }
var _state = null

var path = []
var target_point_world = Vector2()
var target_position = Vector2()
var previous_position = Vector2()

var velocity = Vector2()

var max_movement = 4
var moved = false
var selected = false
var items = []
var randomiser = RandomNumberGenerator.new()
var moving = false

onready var _root = get_node("root/Game")
onready var _cursor_grid = get_parent().get_parent()
onready var _tile_grid = _cursor_grid.get_parent()
onready var _cursor = _cursor_grid.get_node("Cursor")
onready var _plant_factory = _cursor_grid.get_node("PlantFactory")

func _ready():
	_change_state(STATES.IDLE)
	$SlugSprite.modulate = Color(0.8,0.8,0.8,0.8)
	_cursor_grid.set_cellv(_cursor_grid.world_to_map(position), 1)
	self.connect("tree_exited", _root, 'state_changed')


func _change_state(new_state):
	if new_state == STATES.READY:
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
	if new_state == STATES.READY:
		_change_state(STATES.FOLLOW)


func _process(delta):
	var current_tile = _tile_grid.world_to_map(position)
	if not _state == STATES.FOLLOW:
		_cursor_grid.set_cellv(current_tile, 1)
		return
	moved = true
	selected = false
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		if len(path) == 0:
			var adjacent_characters = _cursor_grid.find_adjacents(position)
			var adjacent_cells = _tile_grid.find_adjacent_cell_values(position)
			if len(adjacent_characters) > 0:
				_cursor_grid.set_cellv(_cursor_grid.world_to_map(adjacent_characters[0].position), -1)
				adjacent_characters[0].queue_free()
				print('chomp')
			elif _tile_grid.get_cellv(_tile_grid.world_to_map(position)) == 3:
				for plant in _plant_factory.get_children():
					if plant.position.distance_to(position) < 20:
						plant.queue_free()
						print('chomp')
						_tile_grid.set_cellv(_tile_grid.world_to_map(position), -1)
			_change_state(STATES.IDLE)
			moving = false
			return
		target_point_world = path[0]


func move_to(world_position):
	var MASS = 10.0
	var ARRIVE_DISTANCE = 10.0
	var random_vector = Vector2(randomiser.randf()*40, randomiser.randf()*40)
	var desired_velocity = (world_position - position).normalized() * SPEED + random_vector
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	position += velocity * get_process_delta_time()
	rotation = velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE
	
	
func start_movement(target, new_path):
	target_position = target
	path = new_path
	_tile_grid.disable_point(target_position)
	_tile_grid.enable_point(position)
	moving = true
	_change_state(STATES.READY)
	while moving:
		yield(get_tree().create_timer(0.8), "timeout")
		print('wait')
	return position

func move(event):
	previous_position = position
	_cursor_grid.set_cellv(_cursor_grid.world_to_map(position), -1)
	_change_state(STATES.FOLLOW)

func _on_End_Turn_pressed():
	moved = false
	selected = false
	$SlugSprite.modulate = Color(0.8,0.8,0.8,0.8)
