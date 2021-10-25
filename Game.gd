extends Node

var current_turn = 1
var player_turn = true
onready var curTurnText : Label = get_node("TileMap/CursorMap/Cursor/Camera2D/UI/ColorRect/TurnCounter")


func _ready():
	pass


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_E:
			_on_End_Turn_pressed()


func _on_End_Turn_pressed():
	if player_turn:
		current_turn += 1
		curTurnText.text = "Turn " + str(current_turn)
		player_turn = false
		$TileMap.clear_path()
		for character in get_node("TileMap/CursorMap/CharacterFactory").get_children():
			character._on_End_Turn_pressed()
		for plant in get_node("TileMap/CursorMap/PlantFactory").get_children():
			plant._on_End_Turn_pressed()
		$TileMap/CursorMap/Cursor.pause_cursor()
		$TileMap/CursorMap/SlugFactory.enemy_turn()
		$TileMap/CursorMap/Cursor.unpause_cursor()
