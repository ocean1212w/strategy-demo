extends Position2D

export(float) var SPEED = 200.0

enum STATES { IDLE, READY, FOLLOW }
var _state = null

var path = []
var target_point_world = Vector2()
var target_position = Vector2()

var velocity = Vector2()

var max_movement = 8
var moved = false

func _ready():
	_change_state(STATES.IDLE)


func _change_state(new_state):
	if new_state == STATES.READY:
		path = get_parent().get_parent().find_path(position, target_position, max_movement)
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return
		if len(path) < max_movement + 2:
			target_point_world = path[1]
		else:
			_change_state(STATES.IDLE)
			return
	_state = new_state


func _process(delta):
	if not _state == STATES.FOLLOW:
		return
	moved = true
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		if len(path) == 0:
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


func _input(event):
	if event is InputEventKey:
		if not moved:
			if event.pressed and event.scancode == KEY_E and _state == STATES.READY:
				_change_state(STATES.FOLLOW)
			elif event.pressed and event.scancode == KEY_Q:
				target_position = get_parent().get_global_cursor()
				_change_state(STATES.READY)


func _on_End_Turn_pressed():
	moved = false
