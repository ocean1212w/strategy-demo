extends Node


var current_turn = 1
onready var curTurnText : Label = get_node("TileMap/CursorMap/Cursor/Camera2D/UI/ColorRect/TurnCounter")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_E:
			_on_End_Turn_pressed()
			


func _on_End_Turn_pressed():
	current_turn += 1
	curTurnText.text = "Turn " + str(current_turn)
	var grid = get_node("TileMap")
	grid.clear_previous_path_drawing()
	grid._point_path = []
	grid.update()
	for character in get_node("TileMap/CursorMap").get_children():
		character._on_End_Turn_pressed()
