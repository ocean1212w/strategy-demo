extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func enemy_turn():
	print('slug turn!')
	for slug in get_children():
		var target_position = get_path_towards_closest_character(slug.position, 4)
		slug.start_movement(Vector2(500, 80), get_parent().get_parent().find_path(slug.position, Vector2(500, 80), 8, false))
	get_node('/root/Game').player_turn = true

func get_path_towards_closest_character(slug_position, slug_movement):
	var paths = []
	var long_paths = []
	var plant_long_paths = []
	for character in get_parent().get_node("CharacterFactory").get_children():
		var character_position = get_parent().world_to_map(character.position)
		var world_path = get_parent().get_parent().find_path(slug_position, character_position, slug_movement, true)
		if len(world_path) <= slug_movement:
			paths.append(world_path)
		else:
			long_paths.append(world_path)
	if len(paths) > 0:
		return ''
	for character in get_parent().get_node("PlantFactory").get_children():
		var plant_position = get_parent().world_to_map(character.position)
		var world_path = get_parent().get_parent().find_path(slug_position, plant_position, slug_movement, true)
		if len(world_path) <= slug_movement:
			paths.append(world_path)
		else:
			long_paths.append(world_path)
	if len(paths) > 0:
		return ''
		
	
