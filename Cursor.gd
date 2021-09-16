extends Position2D

enum CELL_TYPES{ ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

onready var Grid = get_parent()

func _ready():
	pass

func _process(delta):
	var input_direction = get_input_direction()
	if not input_direction:
		return
	var target_position = Grid.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
		

func get_input_direction():
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

func move_to(target_position):
	set_process(false)

	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell
	var move_direction = (target_position - position).normalized()
	$Tween.interpolate_property(
		self,"position",
		position,target_position,
		0.2,
		Tween.TRANS_LINEAR, Tween.EASE_IN)

	$Tween.start()
	for child in get_parent().get_children():
		if child != get_node("."):
			child.draw_path()
	
	set_process(true)
