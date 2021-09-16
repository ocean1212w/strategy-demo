extends Node


var current_turn = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_End_Turn_pressed():
	get_node("UI").end_of_turn()
	get_node("TileMap").clear_previous_path_drawing()
