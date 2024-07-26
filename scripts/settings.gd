extends Node2D

var sens = 100

func _physics_process(delta):
	var slider = get_node("Brightness_slider")
	sens = slider.value
	print(sens)
