extends Camera2D

onready var node_to_follow = get_node("../TileMap/CursorMap/Cursor")

func _process(delta):
	position = node_to_follow.position

func reposition(node):
	node_to_follow = node

func return_to_cursor():
	var cursor = get_node("../TileMap/CursorMap/Cursor")
	reposition(cursor)
