extends Node2D

export(PackedScene) var plant_scene = preload("res://Plant.tscn")

func _ready():
	pass 

func spawn_plant(position):
	var instance = plant_scene.instance()
	instance.global_position = position
	add_child(instance)

func _on_End_Turn_pressed():
#	needs to be here for character end turn loop
	for child in get_children():
		child._on_End_Turn_pressed()
