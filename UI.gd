extends Control


onready var curTurnText : Label = get_node("TurnCounter")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func end_of_turn():
	get_parent().current_turn += 1
	curTurnText.text = "Turn " + str(get_parent().current_turn)
