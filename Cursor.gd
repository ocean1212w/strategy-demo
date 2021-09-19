extends Position2D

enum CELL_TYPES{ ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

onready var Grid = get_parent()
onready var DescriptionLabel = get_node("Camera2D/UI/ColorRect/CursorDescription")
var paused = false

var label_dict = {
			-1: "Ground",
			0: "Terrain",
			1: "Farmer",
			2: "Target Tile"
		}

func _ready():
	pass

func _process(delta):
	if paused:
		return
	var input_direction = get_input_direction()
	if not input_direction:
		return
	var target_position = Grid.request_move(self, input_direction)
	if target_position:
		var label = label_dict[Grid.get_parent().get_cellv(Grid.world_to_map(target_position))]
		DescriptionLabel.text = label
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
	
func _on_End_Turn_pressed():
#	needs to be here for character end turn loop
	pass
	
func pause_cursor():
	paused = true

func unpause_cursor():
	paused = false
