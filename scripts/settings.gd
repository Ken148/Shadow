extends Node

var sens = 100

func _physics_process(delta):
	sens = $Brightness_slider.value

func _on_pressed():
	sens = $Brightness_slider.value
