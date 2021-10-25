extends Node2D

var turns_alive = 0
var grown = false

func _ready():
	pass

func _on_End_Turn_pressed():
#	needs to be here for character end turn loop
	turns_alive += 1
	if turns_alive < 6:
		scale *= 1.2
	if turns_alive == 10:
		get_node("Sprite").modulate = Color (0.1, 0.1, 0.1, 1)
		scale *= 0.5
		grown = false
	if turns_alive == 6:
		get_node("Sprite").modulate = Color(2, 2, 0.2, 1)
		grown = true
