extends Node2D

var width
var path
var half_cell_size

const DRAW_COLOR = Color('#fff')
const ERROR_COLOR = Color('#f00')

func _draw():
	if path:
		var point_start = path[0]
		var point_end = path[len(path) - 1]
		var last_point = get_parent().map_to_world(Vector2(point_start.x, point_start.y)) + half_cell_size	
		for index in range(1, len(path)):
			var current_point = get_parent().map_to_world(Vector2(path[index].x, path[index].y)) + half_cell_size
			var draw_colour
			if index < 8:
				draw_colour = DRAW_COLOR
			else:
				draw_colour = ERROR_COLOR
			draw_line(last_point, current_point, draw_colour, width, true)
			draw_circle(current_point, width * 2.0, draw_colour)
			last_point = current_point
		

func draw_path(point_path, new_half_cell_size, new_width):
	path = point_path
	half_cell_size = new_half_cell_size
	width = new_width
	update()
