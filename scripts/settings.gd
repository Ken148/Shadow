extends Node2D

var sens: float

func _ready():
	var sens = get_tree().get_first_node_in_group("Main_scene/Player")

func _physics_process(delta):
	var slider = get_node("Brightness_slider")
	sens = slider.value
	print(sens)
