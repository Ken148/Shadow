extends Button

func _pressed():
	# changing to main_menu 
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
