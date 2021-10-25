extends Position2D

enum CELL_TYPES{ ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

onready var Grid = get_parent()
onready var DescriptionLabel = get_node("Camera2D/UI/ColorRect/CursorDescription")
var paused = false
var info_panel = false

var label_dict = {
			-1: "Ground",
			0: "Terrain",
			2: "Target Tile",
			3: "Soil",
			6: 'House',
			7: 'House'
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
	$InfoPanels/PlantPanel.visible = false
	$InfoPanels/CharacterPanel.visible = false
	if target_position:
		var label = label_dict[Grid.get_parent().get_cellv(Grid.world_to_map(target_position))]
		DescriptionLabel.text = label
		check_for_info_panel(target_position)
		move_to(target_position)
	else:
		check_for_info_panel(position)
		

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
	for child in get_parent().get_node("CharacterFactory").get_children():
		child.draw_path()
	
	set_process(true)
	
func _on_End_Turn_pressed():
#	needs to be here for character end turn loop
	pass
	
func pause_cursor():
	paused = true
	print('pause')

func unpause_cursor():
	paused = false
	print('unpause')

func _input(event):
	if event is InputEventKey and not paused:
		if event.pressed and event.scancode == KEY_I:
			info_panel = not info_panel
			print(info_panel)
			if not info_panel:
				$InfoPanels/PlantPanel.visible = false
				$InfoPanels/CharacterPanel.visible = false
			else:
				check_for_info_panel(position)

func check_for_info_panel(check_position):
	for plant in get_parent().get_node("PlantFactory").get_children():
		if info_panel and Grid.world_to_map(plant.position) == Grid.world_to_map(check_position):
			$InfoPanels/PlantPanel.visible = true
	for character in get_parent().get_node("CharacterFactory").get_children() + get_parent().get_node("SlugFactory").get_children():
		if info_panel and Grid.world_to_map(character.position) == Grid.world_to_map(check_position):
			$InfoPanels/CharacterPanel.visible = true
