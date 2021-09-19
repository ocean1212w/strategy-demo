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

onready var _pm = $PopupMenu
onready var _cursor_grid = get_parent()
onready var _tile_grid = _cursor_grid.get_parent()
onready var _cursor = _cursor_grid.get_node("Cursor")
onready var DescriptionLabel = _cursor_grid.get_node("Cursor/Camera2D/UI/ColorRect/CursorDescription")

func _ready():
	_change_state(STATES.IDLE)
	get_node("Sprite").modulate = Color(0.8,0.8,0.8,0.8)
	_default_pm()
	_pm.connect("id_pressed", self, "_popup_selected")


func _change_state(new_state):
	if new_state == STATES.READY:
		path = _tile_grid.find_path(position, target_position, max_movement)
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return
		if len(path) < max_movement + 2 and DescriptionLabel.text == 'Ground':
			target_point_world = path[1]
		else:
			_change_state(STATES.IDLE)
			return
	_state = new_state


func _process(delta):
	var current_tile = _tile_grid.world_to_map(position)
	_tile_grid.set_cellv(current_tile, 1)
	if not _state == STATES.FOLLOW:
		if _state == STATES.READY:
			get_node("Sprite").modulate = Color(1,1,1,0.8)
		return
	moved = true
	selected = false
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		if len(path) == 0:
			var adjacent_characters = _tile_grid.find_adjacents(position)
			var options = [PopupIds.TALK1, PopupIds.TALK2, PopupIds.TALK3, PopupIds.TALK4]
			for character in adjacent_characters:
				var option = options.pop_front()
				_pm.add_item("Talk to " + character.name, option)
				_pm.set_item_metadata(option, character)
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
	if id == PopupIds.TALK1:
		var character = _pm.get_item_metadata(PopupIds.TALK1)
		print("talking with " + character.name)
		get_node("Sprite").modulate = Color(0.5,0.5,0.5,0.5)
	if id == PopupIds.TALK2:
		var character = _pm.get_item_metadata(PopupIds.TALK2)
		print("talking with " + character.name)
		get_node("Sprite").modulate = Color(0.5,0.5,0.5,0.5)
	if id == PopupIds.TALK3:
		var character = _pm.get_item_metadata(PopupIds.TALK3)
		print("talking with " + character.name)
		get_node("Sprite").modulate = Color(0.5,0.5,0.5,0.5)
	if id == PopupIds.TALK4:
		var character = _pm.get_item_metadata(PopupIds.TALK4)
		print("talking with " + character.name)
		get_node("Sprite").modulate = Color(0.5,0.5,0.5,0.5)
	if id == PopupIds.CANCEL:
		moved = false
		selected = false
		position = previous_position
		_cursor.position = previous_position
	_tile_grid.clear_path()
	_cursor.unpause_cursor()		

func _default_pm():
	_pm.clear()
	_pm.add_item("Wait", PopupIds.WAIT)
	_pm.add_item("Cancel", PopupIds.CANCEL)
