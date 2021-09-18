extends Control


onready var curTurnText : Label = get_node("ColorRect/TurnCounter")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func end_of_turn():
	curTurnText.text = "Turn " + str(get_node('/root/Game').current_turn)
