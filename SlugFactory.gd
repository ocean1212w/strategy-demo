extends Node2D

onready var _cursor = get_parent().get_node("Cursor")
onready var _tiles = get_parent().get_parent()
onready var _cursor_map = get_parent()
onready var _camera = get_node('/root/Game/Camera2D')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func enemy_turn():
	_cursor.pause_cursor()
	print('slug turn!')
	for slug in get_children():
		_camera.reposition(slug)
		var path = get_path_towards_closest_character(slug.position, slug.max_movement)
		if len(path) < 2:
			continue
		var target_position = path[-1]
#		var target_position = slug.position + Vector2(80, 0)
#		var path = get_parent().get_parent().find_path(slug.position, target_position, slug.max_movement, true)
		yield(slug.start_movement(target_position, path), "completed")
	get_node('/root/Game').player_turn = true
	_camera.return_to_cursor()
	_cursor.unpause_cursor()

func get_path_towards_closest_character(slug_position, slug_movement):
	var paths = []
	var long_paths = []
	for character in get_parent().get_node("CharacterFactory").get_children():
		for adjacent in _tiles.find_adjacent_cells(get_parent().world_to_map(character.position)):
			if _tiles.is_outside_map_bounds(adjacent):
				continue
			var world_path = _tiles.find_path(slug_position, _tiles.map_to_world(adjacent), slug_movement, true)
			if len(world_path) <= slug_movement:
				paths.append(world_path)
			else:
				long_paths.append(world_path)
	if len(paths) > 0:
		print('character path')
		return shortest_path(paths)
	for plant in get_parent().get_node("PlantFactory").get_children():
		var world_path = _tiles.find_path(slug_position, plant.position, slug_movement, true)
		if len(world_path) <= slug_movement:
			paths.append(world_path)
		else:
			long_paths.append(world_path)
	if len(paths) > 0:
		print('plant path')
		return shortest_path(paths)
	print('long path')
	if long_paths == []:
		return []
	return shortest_path(long_paths).slice(0,slug_movement)

func shortest_path(paths):
	var current = paths.pop_front()
	for path in paths:
		if len(current) > len(path):
			current = path
	return current
